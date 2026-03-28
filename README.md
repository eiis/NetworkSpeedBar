# NetworkSpeedBar

A lightweight macOS menu bar app that shows real-time network upload/download speed. No Dock icon, no windows — lives entirely in the menu bar.

```
↑ 1.24 MB/s
↓ 3.87 MB/s
```

## Installation

### Direct download

Download the latest `NetworkSpeedBar.zip` from the [Releases](https://github.com/eiis/NetworkSpeedBar/releases/latest) page, unzip it, and move `NetworkSpeedBar.app` to your `/Applications` folder.

### Homebrew

```bash
brew install --cask eiis/tap/networkspeedbar
```

### Build from source

```bash
git clone https://github.com/eiis/NetworkSpeedBar.git
cd NetworkSpeedBar
open NetworkSpeedBar.xcodeproj
```

In Xcode, select the `NetworkSpeedBar` target, go to **Signing & Capabilities**, choose your Apple ID team, then press `⌘R`.

## Requirements

- macOS 13.0 Ventura or later
- Xcode 15+ / Swift 5.9+ (build from source only)

## Usage

### Menu bar display

The status item shows two rows of text in a monospaced font:

```
↑ 1.24 MB/s   ← upload speed
↓ 3.87 MB/s   ← download speed
```

All active network interfaces are included (Wi-Fi, Ethernet, VPN, etc.). Loopback (`lo0`) is excluded.

### Menu

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

Settings are saved to `UserDefaults` and persist across launches.

**Auto unit** selects the most readable unit: `B/s` → `KB/s` → `MB/s` → `GB/s`.

## How It Works

Every tick, `NetworkMonitor` calls `getifaddrs` to read cumulative byte counters (`ifi_ibytes` / `ifi_obytes`) from all active, non-loopback link-layer interfaces. The delta from the previous snapshot divided by elapsed time gives bytes/second. Session totals are tracked separately for the menu display.

## Project Structure

```
NetworkSpeedBar/
├── AppDelegate.swift
├── NetworkSpeedBarApp.swift
├── Core/
│   ├── NetworkMonitor.swift            # getifaddrs sampling, speed delta calculation
│   └── SpeedFormatter.swift           # Byte/speed formatting
├── Model/
│   ├── SpeedSnapshot.swift            # Snapshot struct for delta calculation
│   └── AppSettings.swift              # Settings + UserDefaults persistence
├── MenuBar/
│   └── StatusBarController.swift      # NSStatusItem, menu, Combine bindings
├── Settings/
│   ├── PreferencesView.swift
│   └── PreferencesWindowController.swift
└── Resources/
    └── Info.plist                     # LSUIElement = YES (no Dock icon)
```

## Roadmap

- [ ] 60-second sparkline chart in the popover
- [ ] Per-process traffic breakdown (requires Network Extension)
- [ ] Monthly data cap alerts
- [ ] Launch at login

## License

MIT
