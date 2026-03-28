# TODO

## 已完成

- [x] 建立 macOS 菜单栏应用基础源码结构
- [x] 实现基于 `getifaddrs` 的网络接口字节采样
- [x] 实现上传 / 下载速率格式化
- [x] 实现菜单栏实时速率显示
- [x] 实现基础下拉菜单与退出入口
- [x] 添加 `LSUIElement` 所需 `Info.plist`
- [x] 创建 Xcode 工程生成配置 `project.yml`
- [x] 生成可直接打开的 `NetworkSpeedBar.xcodeproj`
- [x] 在 target 中关联 `NetworkSpeedBar/Resources/Info.plist`
- [x] 实现偏好设置窗口
- [x] 支持刷新间隔配置：0.5s / 1s / 2s
- [x] 支持显示单位固定为自动 / KB/s / MB/s
- [x] 支持接口过滤：全部 / Wi-Fi / 有线 / 指定接口
- [x] 增加累计流量重置功能

## 待完成

- [ ] 实现开机自启动能力（LaunchAgent 或 `SMAppService`）
- [ ] 为上传 / 下载状态文字增加彩色或主题化显示
- [ ] 增加过去 60 秒历史速率缓存，为图表做准备
- [ ] 增加异常场景处理：接口切换、睡眠唤醒、计数器回绕
- [ ] 补充单元测试：格式化、速率计算、接口过滤
- [ ] 补充 README，说明如何在 Xcode 中运行
