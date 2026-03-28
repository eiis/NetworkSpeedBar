import Foundation

enum SpeedFormatter {
    static func formatSpeed(_ bytesPerSecond: UInt64, preference: DisplayUnitPreference = .automatic) -> String {
        switch preference {
        case .automatic:
            switch bytesPerSecond {
            case 0..<1_024:
                return "\(bytesPerSecond) B/s"
            case 1_024..<1_048_576:
                return String(format: "%.1f KB/s", Double(bytesPerSecond) / 1_024)
            case 1_048_576..<1_073_741_824:
                return String(format: "%.2f MB/s", Double(bytesPerSecond) / 1_048_576)
            default:
                return String(format: "%.2f GB/s", Double(bytesPerSecond) / 1_073_741_824)
            }
        case .kilobytes:
            return String(format: "%.1f KB/s", Double(bytesPerSecond) / 1_024)
        case .megabytes:
            return String(format: "%.2f MB/s", Double(bytesPerSecond) / 1_048_576)
        }
    }

    static func formatBytes(_ bytes: UInt64) -> String {
        switch bytes {
        case 0..<1_024:
            return "\(bytes) B"
        case 1_024..<1_048_576:
            return String(format: "%.1f KB", Double(bytes) / 1_024)
        case 1_048_576..<1_073_741_824:
            return String(format: "%.2f MB", Double(bytes) / 1_048_576)
        default:
            return String(format: "%.2f GB", Double(bytes) / 1_073_741_824)
        }
    }
}
