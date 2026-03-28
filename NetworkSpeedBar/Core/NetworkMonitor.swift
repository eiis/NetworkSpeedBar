import CoreWLAN
import Darwin
import Foundation

struct NetworkTotals {
    let rxBytes: UInt64
    let txBytes: UInt64
    let activeInterfaces: [String]
}

struct NetworkSpeed {
    let rxBytesPerSecond: UInt64
    let txBytesPerSecond: UInt64
    let activeInterfaces: [String]
    let totalRxBytes: UInt64
    let totalTxBytes: UInt64
}

final class NetworkMonitor {
    private var lastSnapshot: SpeedSnapshot?
    private var accumulatedRxBytes: UInt64 = 0
    private var accumulatedTxBytes: UInt64 = 0

    func sample() -> NetworkSpeed {
        let totals = readNetworkTotals()
        let now = Date()
        let currentSnapshot = SpeedSnapshot(
            rxBytes: totals.rxBytes,
            txBytes: totals.txBytes,
            timestamp: now
        )

        defer { lastSnapshot = currentSnapshot }

        guard let lastSnapshot else {
            return NetworkSpeed(
                rxBytesPerSecond: 0,
                txBytesPerSecond: 0,
                activeInterfaces: totals.activeInterfaces,
                totalRxBytes: accumulatedRxBytes,
                totalTxBytes: accumulatedTxBytes
            )
        }

        let interval = max(now.timeIntervalSince(lastSnapshot.timestamp), 0.001)
        let rxDelta = totals.rxBytes >= lastSnapshot.rxBytes ? totals.rxBytes - lastSnapshot.rxBytes : 0
        let txDelta = totals.txBytes >= lastSnapshot.txBytes ? totals.txBytes - lastSnapshot.txBytes : 0

        accumulatedRxBytes &+= rxDelta
        accumulatedTxBytes &+= txDelta

        return NetworkSpeed(
            rxBytesPerSecond: UInt64(Double(rxDelta) / interval),
            txBytesPerSecond: UInt64(Double(txDelta) / interval),
            activeInterfaces: totals.activeInterfaces,
            totalRxBytes: accumulatedRxBytes,
            totalTxBytes: accumulatedTxBytes
        )
    }

    func resetStatistics() {
        let totals = readNetworkTotals()
        lastSnapshot = SpeedSnapshot(
            rxBytes: totals.rxBytes,
            txBytes: totals.txBytes,
            timestamp: Date()
        )
        accumulatedRxBytes = 0
        accumulatedTxBytes = 0
    }

    private func readNetworkTotals() -> NetworkTotals {
        var totalRx: UInt64 = 0
        var totalTx: UInt64 = 0
        var interfaces = Set<String>()

        var ifaddrPointer: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddrPointer) == 0, let firstAddress = ifaddrPointer else {
            return NetworkTotals(rxBytes: 0, txBytes: 0, activeInterfaces: [])
        }
        defer { freeifaddrs(ifaddrPointer) }

        var cursor: UnsafeMutablePointer<ifaddrs>? = firstAddress
        while let interface = cursor {
            let ifa = interface.pointee
            guard let address = ifa.ifa_addr else {
                cursor = ifa.ifa_next
                continue
            }

            let interfaceName = String(cString: ifa.ifa_name)
            let flags = Int32(ifa.ifa_flags)

            let isLinkLayer = address.pointee.sa_family == UInt8(AF_LINK)
            let isLoopback = (flags & IFF_LOOPBACK) != 0 || interfaceName.hasPrefix("lo")
            let isUp = (flags & IFF_UP) != 0
            let isRunning = (flags & IFF_RUNNING) != 0

            guard isLinkLayer, !isLoopback, isUp, isRunning else {
                cursor = ifa.ifa_next
                continue
            }

            guard let rawData = ifa.ifa_data else {
                cursor = ifa.ifa_next
                continue
            }

            let data = rawData.assumingMemoryBound(to: if_data.self).pointee
            totalRx &+= UInt64(data.ifi_ibytes)
            totalTx &+= UInt64(data.ifi_obytes)
            interfaces.insert(interfaceName)

            cursor = ifa.ifa_next
        }

        return NetworkTotals(
            rxBytes: totalRx,
            txBytes: totalTx,
            activeInterfaces: interfaces.sorted()
        )
    }
}
