# NetworkSpeedBar

A lightweight macOS menu bar app that shows real-time network upload/download speed. No Dock icon, no windows — lives entirely in the menu bar.

```
↑ 1.24 MB/s
↓ 3.87 MB/s
```

## Requirements

- macOS 13.0 Ventura or later
- Xcode 15+
- Swift 5.9+
- No third-party dependencies

## Installation

### Build from source

```bash
git clone https://github.com/eiis/NetworkSpeedBar.git
cd NetworkSpeedBar
open NetworkSpeedBar.xcodeproj
```

In Xcode:

1. Select the `NetworkSpeedBar` target
2. Go to **Signing & Capabilities**, choose your Apple ID team (a free account works)
3. Press `⌘R` to build and run

The app will appear in your menu bar immediately. Since it has no Dock icon (`LSUIElement = YES`), it only lives in the menu bar.

## Usage

### Menu bar display

The status item shows two rows of text in a monospaced font:

```
↑ 1.24 MB/s   ← upload speed
↓ 3.87 MB/s   ← download speed
```

All active network interfaces are included (Wi-Fi, Ethernet, VPN, etc.). Loopback (`lo0`) is excluded.

### Clicking the menu bar item

Click the speed display to open the menu:

| Item | Description |
|------|-------------|
| 本次上传 / 本次下载 | Session traffic totals since last reset |
| 刷新间隔 | Current refresh interval |
| 显示单位 | Current speed unit setting |
| 重置统计 (`R`) | Reset session upload/download counters |
| 偏好设置... (`,`) | Open preferences window |
| 退出 (`Q`) | Quit the app |

### Preferences

Open **偏好设置...** from the menu to adjust:

| Setting | Options | Default |
|---------|---------|---------|
| 刷新间隔 (Refresh interval) | 0.5s / 1s / 2s | 1s |
| 显示单位 (Speed unit) | Auto / Fixed KB/s / Fixed MB/s | Auto |

Settings are saved automatically to `UserDefaults` and persist across launches.

**Auto unit** selects the most readable unit:
- `B/s` — under 1 KB/s
- `KB/s` — under 1 MB/s
- `MB/s` — under 1 GB/s
- `GB/s` — 1 GB/s and above

## Project Structure

```
NetworkSpeedBar/
├── AppDelegate.swift                   # App entry, bootstraps StatusBarController
├── NetworkSpeedBarApp.swift            # @main
├── Core/
│   ├── NetworkMonitor.swift            # getifaddrs sampling, speed delta calculation
│   └── SpeedFormatter.swift           # Byte/speed formatting
├── Model/
│   ├── SpeedSnapshot.swift            # Snapshot struct for delta calculation
│   └── AppSettings.swift              # ObservableObject settings + UserDefaults persistence
├── MenuBar/
│   └── StatusBarController.swift      # NSStatusItem, menu, Combine bindings
├── Settings/
│   ├── PreferencesView.swift          # SwiftUI preferences UI
│   └── PreferencesWindowController.swift
└── Resources/
    └── Info.plist                     # LSUIElement = YES
```

## How It Works

Every tick, `NetworkMonitor` calls `getifaddrs` to read cumulative byte counters (`ifi_ibytes` / `ifi_obytes`) from all active, non-loopback link-layer interfaces. The delta from the previous snapshot divided by the elapsed time gives bytes/second. Accumulated totals are tracked separately for the session traffic display.

## Roadmap

- [ ] 60-second sparkline chart in the popover
- [ ] Per-process traffic breakdown (requires Network Extension)
- [ ] Monthly data cap alerts
- [ ] Launch at login
- [ ] Homebrew Cask

## License

MIT
