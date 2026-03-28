# NetworkSpeedBar

<p align="center">
  <a href="https://github.com/eiis/NetworkSpeedBar/blob/main/LICENSE"><img src="https://img.shields.io/badge/License-MIT-yellow.svg" alt="License: MIT"></a>
  <a href="https://swift.org"><img src="https://img.shields.io/badge/Swift-5.9+-orange.svg" alt="Swift 5.9+"></a>
  <a href="https://www.apple.com/macos/ventura/"><img src="https://img.shields.io/badge/macOS-13.0+-blue.svg" alt="macOS 13.0+"></a>
  <a href="https://github.com/eiis/NetworkSpeedBar/releases/latest"><img src="https://img.shields.io/github/v/release/eiis/NetworkSpeedBar" alt="最新版本"></a>
  <a href="https://github.com/eiis/NetworkSpeedBar/releases/latest"><img src="https://img.shields.io/github/downloads/eiis/NetworkSpeedBar/total" alt="下载次数"></a>
</p>

<p align="center">📶 轻量级 macOS 菜单栏网速监控，无 Dock 图标，无窗口</p>

<p align="center">
  <a href="./README.md">English</a> ·
  <a href="https://github.com/eiis/NetworkSpeedBar/releases/latest">下载</a> ·
  <a href="https://github.com/eiis/NetworkSpeedBar/issues">反馈</a>
</p>

---

## ✨ 功能特性

- **实时速率** — 上传和下载速率每秒更新
- **常驻菜单栏** — 无 Dock 图标，无窗口，始终可见
- **智能单位** — 自动选择最合适的显示单位：`B/s` → `KB/s` → `MB/s` → `GB/s`
- **全接口统计** — 同时覆盖 Wi-Fi、有线、VPN 等所有活跃网络接口
- **本次流量** — 记录本次运行的累计上传/下载量，支持手动重置
- **极致轻量** — CPU < 0.5%，内存 < 10 MB，零第三方依赖

---

## 📦 安装

### 直接下载

从 [Releases](https://github.com/eiis/NetworkSpeedBar/releases/latest) 页面下载最新的 `NetworkSpeedBar.zip`，解压后将 `NetworkSpeedBar.app` 移动到 `/Applications` 文件夹即可。

### Homebrew

```bash
brew install --cask eiis/tap/networkspeedbar
```

### 从源码编译

```bash
git clone https://github.com/eiis/NetworkSpeedBar.git
cd NetworkSpeedBar
open NetworkSpeedBar.xcodeproj
```

在 Xcode 中选择 `NetworkSpeedBar` target → **Signing & Capabilities** → 选择你的 Apple ID 团队 → 按 `⌘R` 运行。

> **系统要求：** macOS 13.0 Ventura 及以上。仅源码编译需要 Xcode 15+ / Swift 5.9+。

---

## 🖥 使用说明

### 菜单栏显示

状态栏以等宽字体分两行显示：

```
↑ 1.24 MB/s
↓ 3.87 MB/s
```

### 菜单

点击速率显示区域展开菜单：

| 菜单项 | 说明 |
|--------|------|
| 本次上传 / 本次下载 | 本次运行的累计流量 |
| 刷新间隔 | 当前采样频率 |
| 显示单位 | 当前单位偏好 |
| 重置统计 `R` | 清零本次累计流量 |
| 偏好设置... `,` | 打开偏好设置窗口 |
| 退出 `Q` | 退出应用 |

### 偏好设置

| 设置项 | 可选值 | 默认值 |
|--------|--------|--------|
| 刷新间隔 | 0.5 秒 / 1 秒 / 2 秒 | 1 秒 |
| 显示单位 | 自动 / 固定 KB/s / 固定 MB/s | 自动 |

设置通过 `UserDefaults` 自动持久化，重启后保留。

---

## ⚙️ 工作原理

每次刷新，`NetworkMonitor` 通过 `getifaddrs` 读取所有活跃非回环网络接口的累计字节数（`ifi_ibytes` / `ifi_obytes`），与上次快照做差值并除以时间间隔，得到当前速率。本次累计流量单独维护，用于菜单显示。

---

## 📁 项目结构

```
NetworkSpeedBar/
├── AppDelegate.swift
├── NetworkSpeedBarApp.swift
├── Core/
│   ├── NetworkMonitor.swift            # getifaddrs 采样，速率差值计算
│   └── SpeedFormatter.swift           # 字节/速率格式化
├── Model/
│   ├── SpeedSnapshot.swift            # 采样快照结构体
│   └── AppSettings.swift              # 设置项 + UserDefaults 持久化
├── MenuBar/
│   └── StatusBarController.swift      # NSStatusItem、菜单、Combine 绑定
├── Settings/
│   ├── PreferencesView.swift
│   └── PreferencesWindowController.swift
└── Resources/
    └── Info.plist                     # LSUIElement = YES（隐藏 Dock 图标）
```

---

## 🗺 后续计划

- [ ] 60 秒网速折线图（在下拉 popover 中显示）
- [ ] 按进程显示流量（需要 Network Extension 权限）
- [ ] 月度流量超限提醒
- [ ] 开机自启动

---

## 📄 许可证

[MIT](./LICENSE) © 2026 eiis
