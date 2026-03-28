# NetworkSpeedBar

<p align="center">
  <a href="https://github.com/eiis/NetworkSpeedBar/blob/main/LICENSE"><img src="https://img.shields.io/badge/License-MIT-yellow.svg" alt="License: MIT"></a>
  <a href="https://swift.org"><img src="https://img.shields.io/badge/Swift-5.9+-orange.svg" alt="Swift 5.9+"></a>
  <a href="https://www.apple.com/macos/ventura/"><img src="https://img.shields.io/badge/macOS-13.0+-blue.svg" alt="macOS 13.0+"></a>
  <a href="https://github.com/eiis/NetworkSpeedBar/releases/latest"><img src="https://img.shields.io/github/v/release/eiis/NetworkSpeedBar" alt="Latest Release"></a>
  <a href="https://github.com/eiis/NetworkSpeedBar/releases/latest"><img src="https://img.shields.io/github/downloads/eiis/NetworkSpeedBar/total" alt="Downloads"></a>
</p>

<p align="center">📶 Lightweight macOS menu bar network speed monitor, no Dock icon, no windows</p>

<p align="center">
  <a href="./README.zh.md">中文</a> ·
  <a href="https://github.com/eiis/NetworkSpeedBar/releases/latest">Download</a> ·
  <a href="https://github.com/eiis/NetworkSpeedBar/issues">Feedback</a>
</p>

---

## ✨ Features

- **Real-time speed** — Upload and download rates updated every second
- **Always visible** — Lives in the menu bar, no Dock icon, no windows
- **Smart units** — Auto-selects the most readable unit: `B/s` → `KB/s` → `MB/s` → `GB/s`
- **All interfaces** — Covers Wi-Fi, Ethernet, VPN and more simultaneously
- **Session stats** — Tracks cumulative upload/download since last reset
- **Lightweight** — CPU < 0.5%, Memory < 10 MB, zero dependencies

---

## 📦 Installation

### Direct Download

Download the latest `NetworkSpeedBar.zip` from the [Releases](https://github.com/eiis/NetworkSpeedBar/releases/latest) page, unzip it, and move `NetworkSpeedBar.app` to your `/Applications` folder.

### Homebrew

```bash
brew install --cask eiis/tap/networkspeedbar
```

### Build from Source

```bash
git clone https://github.com/eiis/NetworkSpeedBar.git
cd NetworkSpeedBar
open NetworkSpeedBar.xcodeproj
```

In Xcode, select the `NetworkSpeedBar` target → **Signing & Capabilities** → choose your Apple ID team → press `⌘R`.

> **Requirements:** macOS 13.0 Ventura or later. Xcode 15+ / Swift 5.9+ required only for building from source.

---

## 🖥 Usage

### Menu Bar Display

The status item shows two rows in a monospaced font:

```
↑ 1.24 MB/s
↓ 3.87 MB/s
```

### Menu

Click the speed display to open the dropdown:

| Item | Description |
|------|-------------|
| Session Upload / Download | Cumulative traffic since last reset |
| Refresh Interval | Current sampling frequency |
| Speed Unit | Current unit preference |
| Reset Statistics `R` | Clear session counters |
| Preferences... `,` | Open the preferences window |
| Quit `Q` | Quit the app |

### Preferences

| Setting | Options | Default |
|---------|---------|---------|
| Refresh interval | 0.5s / 1s / 2s | 1s |
| Speed unit | Auto / Fixed KB/s / Fixed MB/s | Auto |

Settings persist across launches via `UserDefaults`.

---

## ⚙️ How It Works

Every tick, `NetworkMonitor` calls `getifaddrs` to read cumulative byte counters (`ifi_ibytes` / `ifi_obytes`) from all active, non-loopback link-layer interfaces. The delta from the previous snapshot divided by elapsed time gives the current speed in bytes/second. Session totals are tracked separately for the menu display.

---

## 📁 Project Structure

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

---

## 🗺 Roadmap

- [ ] 60-second sparkline chart in the popover
- [ ] Per-process traffic breakdown (requires Network Extension)
- [ ] Monthly data cap alerts
- [ ] Launch at login

---

## 📄 License

[MIT](./LICENSE) © 2026 eiis
