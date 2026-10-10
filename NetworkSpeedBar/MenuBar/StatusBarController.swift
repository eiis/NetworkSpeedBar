import AppKit
import Combine

final class StatusBarController: NSObject {
    private let statusItem: NSStatusItem
    private let settings = AppSettings.shared
    private let networkMonitor = NetworkMonitor()
    private var lastStatusText = ""
    private var preferencesWindowController: PreferencesWindowController?
    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()
    private var totalRxBytes: UInt64 = 0
    private var totalTxBytes: UInt64 = 0

    override init() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        super.init()
        configureStatusItem()
        bindSettings()
        updateSpeed()
        startMonitoring()
    }

    deinit {
        timer?.invalidate()
    }

    private func configureStatusItem() {
        guard let button = statusItem.button else { return }
        button.image = nil
        button.lineBreakMode = .byClipping
        updateStatusLabels(uploadText: "0 B/s", downloadText: "0 B/s")

        let menu = NSMenu()
        menu.autoenablesItems = false
        menu.delegate = self
        statusItem.menu = menu
    }

    private func startMonitoring() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: settings.refreshInterval.timeInterval, repeats: true) { [weak self] _ in
            self?.updateSpeed()
        }
        if let timer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }

    private func bindSettings() {
        settings.$refreshInterval
            .dropFirst()
            .sink { [weak self] _ in
                self?.startMonitoring()
                self?.updateSpeed()
            }
            .store(in: &cancellables)

        settings.$displayUnit
            .dropFirst()
            .sink { [weak self] _ in
                self?.updateSpeed()
            }
            .store(in: &cancellables)

    }

    private func updateSpeed() {
        let speed = networkMonitor.sample()
        totalRxBytes = speed.totalRxBytes
        totalTxBytes = speed.totalTxBytes

        let uploadText = SpeedFormatter.formatSpeed(speed.txBytesPerSecond, preference: settings.displayUnit)
        let downloadText = SpeedFormatter.formatSpeed(speed.rxBytesPerSecond, preference: settings.displayUnit)
        updateStatusLabels(uploadText: uploadText, downloadText: downloadText)
    }

    private func updateStatusLabels(uploadText: String, downloadText: String) {
        // Only touch the status item when the text actually changes: every
        // button update makes AppKit re-render the status bar snapshot.
        let text = "↑ \(uploadText)\n↓ \(downloadText)"
        guard text != lastStatusText, let button = statusItem.button else { return }
        lastStatusText = text

        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .left
        paragraph.lineSpacing = 0
        paragraph.maximumLineHeight = 9
        paragraph.minimumLineHeight = 9
        button.attributedTitle = NSAttributedString(string: text, attributes: [
            .font: NSFont.monospacedSystemFont(ofSize: 8, weight: .regular),
            .paragraphStyle: paragraph,
            .baselineOffset: -1
        ])
    }

    private func rebuildMenu() {
        let menu = NSMenu()

        let uploadItem = NSMenuItem(title: "本次上传: \(SpeedFormatter.formatBytes(totalTxBytes))", action: nil, keyEquivalent: "")
        uploadItem.isEnabled = false
        menu.addItem(uploadItem)

        let downloadItem = NSMenuItem(title: "本次下载: \(SpeedFormatter.formatBytes(totalRxBytes))", action: nil, keyEquivalent: "")
        downloadItem.isEnabled = false
        menu.addItem(downloadItem)

        menu.addItem(.separator())

        let refreshIntervalItem = NSMenuItem(title: "刷新间隔: \(settings.refreshInterval.title)", action: nil, keyEquivalent: "")
        refreshIntervalItem.isEnabled = false
        menu.addItem(refreshIntervalItem)

        let displayUnitItem = NSMenuItem(title: "显示单位: \(settings.displayUnit.title)", action: nil, keyEquivalent: "")
        displayUnitItem.isEnabled = false
        menu.addItem(displayUnitItem)

        menu.addItem(.separator())

        let resetStatsItem = NSMenuItem(title: "重置统计", action: #selector(resetStatisticsFromMenu), keyEquivalent: "r")
        resetStatsItem.target = self
        menu.addItem(resetStatsItem)

        let prefsItem = NSMenuItem(title: "偏好设置...", action: #selector(showPreferences), keyEquivalent: ",")
        prefsItem.target = self
        menu.addItem(prefsItem)

        let launchAtLoginItem = NSMenuItem(title: "开机自启动", action: #selector(toggleLaunchAtLogin), keyEquivalent: "")
        launchAtLoginItem.target = self
        launchAtLoginItem.state = .off
        launchAtLoginItem.isEnabled = false
        menu.addItem(launchAtLoginItem)

        menu.addItem(.separator())

        let quitItem = NSMenuItem(title: "退出", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    @objc
    private func showPreferences() {
        if preferencesWindowController == nil {
            preferencesWindowController = PreferencesWindowController(settings: settings)
        }

        preferencesWindowController?.showWindow(nil)
        preferencesWindowController?.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc
    private func resetStatisticsFromMenu() {
        resetStatistics()
    }

    @objc
    private func toggleLaunchAtLogin() {}

    @objc
    private func quit() {
        NSApplication.shared.terminate(nil)
    }

    private func resetStatistics() {
        networkMonitor.resetStatistics()
        totalRxBytes = 0
        totalTxBytes = 0
        updateSpeed()
    }
}

extension StatusBarController: NSMenuDelegate {
    func menuWillOpen(_ menu: NSMenu) {
        rebuildMenu()
    }
}
