import AppKit
import Combine

final class StatusBarController: NSObject {
    private let statusItem: NSStatusItem
    private let settings = AppSettings.shared
    private let networkMonitor = NetworkMonitor()
    private let uploadArrowLabel = NSTextField(labelWithString: "↑")
    private let uploadLabel = NSTextField(labelWithString: "0 B/s")
    private let downloadArrowLabel = NSTextField(labelWithString: "↓")
    private let downloadLabel = NSTextField(labelWithString: "0 B/s")
    private let speedStackView = NSStackView()
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
        button.title = ""
        button.image = nil
        configureSpeedView(in: button)
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

    private func configureSpeedView(in button: NSStatusBarButton) {
        guard speedStackView.superview == nil else { return }

        let font = NSFont.monospacedSystemFont(ofSize: 8, weight: .regular)
        [uploadLabel, downloadLabel].forEach { label in
            label.font = font
            label.alignment = .left
            label.lineBreakMode = .byClipping
            label.translatesAutoresizingMaskIntoConstraints = false
            label.setContentCompressionResistancePriority(.required, for: .horizontal)
        }
        [uploadArrowLabel, downloadArrowLabel].forEach { label in
            label.font = .systemFont(ofSize: 9, weight: .medium)
            label.alignment = .center
            label.lineBreakMode = .byClipping
            label.translatesAutoresizingMaskIntoConstraints = false
            label.setContentCompressionResistancePriority(.required, for: .horizontal)
        }

        speedStackView.orientation = .vertical
        speedStackView.alignment = .leading
        speedStackView.distribution = .fill
        speedStackView.spacing = 0
        speedStackView.translatesAutoresizingMaskIntoConstraints = false

        let uploadRow = makeSpeedRow(arrowLabel: uploadArrowLabel, valueLabel: uploadLabel)
        let downloadRow = makeSpeedRow(arrowLabel: downloadArrowLabel, valueLabel: downloadLabel)

        speedStackView.addArrangedSubview(uploadRow)
        speedStackView.addArrangedSubview(downloadRow)

        button.addSubview(speedStackView)
        NSLayoutConstraint.activate([
            speedStackView.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 6),
            speedStackView.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -6),
            speedStackView.centerYAnchor.constraint(equalTo: button.centerYAnchor)
        ])
    }

    private func makeSpeedRow(arrowLabel: NSTextField, valueLabel: NSTextField) -> NSStackView {
        let row = NSStackView(views: [arrowLabel, valueLabel])
        row.orientation = .horizontal
        row.alignment = .centerY
        row.distribution = .fill
        row.spacing = 2
        row.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            arrowLabel.widthAnchor.constraint(equalToConstant: 8),
            row.heightAnchor.constraint(equalToConstant: 8)
        ])

        return row
    }

    private func updateStatusLabels(uploadText: String, downloadText: String) {
        uploadLabel.stringValue = uploadText
        downloadLabel.stringValue = downloadText
        statusItem.length = max(ceil(speedStackView.fittingSize.width) + 12, 44)
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
