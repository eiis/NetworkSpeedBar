import AppKit
import SwiftUI

final class PreferencesWindowController: NSWindowController {
    init(settings: AppSettings) {
        let rootView = PreferencesView()
            .environmentObject(settings)

        let hostingController = NSHostingController(rootView: rootView)
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 320, height: 170),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )

        window.title = "偏好设置"
        window.isReleasedWhenClosed = false
        window.contentMinSize = NSSize(width: 320, height: 170)
        window.center()
        window.contentViewController = hostingController

        super.init(window: window)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
