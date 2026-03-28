# NetworkSpeedBar

A lightweight macOS menu bar app that displays real-time network upload and download speed — no windows, no clutter.

```
↑ 256 KB/s   ↓ 1.8 MB/s
```

## Features

- Real-time upload/download speed in the menu bar
- Smart unit formatting: B/s → KB/s → MB/s → GB/s
- Click to expand: interface name, session traffic totals, quit
- Zero dependencies — pure Swift + AppKit/SwiftUI
- CPU < 0.5%, Memory < 10 MB

## Requirements

- macOS 13.0 Ventura or later
- Xcode 15+
- Swift 5.9+

## How It Works

Uses `getifaddrs` to read raw byte counters from all network interfaces (excluding `lo0` loopback) every second. The delta between snapshots gives the current speed.

## Project Structure

```
NetworkSpeedBar/
├── AppDelegate.swift          # NSApplicationDelegate, bootstraps StatusBarController
├── Core/
│   └── NetworkMonitor.swift   # Reads getifaddrs, computes speed deltas
├── Model/
│   └── SpeedSnapshot.swift    # Byte-count snapshot for delta calculation
└── Resources/
    └── Info.plist             # LSUIElement = YES (hides Dock icon)
```

## Getting Started

1. Clone the repo and open `NetworkSpeedBar.xcodeproj` in Xcode
2. Select your personal team in **Signing & Capabilities** (free account works)
3. Build & Run (`⌘R`) — the speed indicator appears in your menu bar immediately

## Roadmap

- [ ] 60-second sparkline chart in the popover
- [ ] Per-process traffic (requires Network Extension entitlement)
- [ ] Monthly data cap alerts
- [ ] Export traffic log as CSV
- [ ] Homebrew Cask distribution

## License

MIT
