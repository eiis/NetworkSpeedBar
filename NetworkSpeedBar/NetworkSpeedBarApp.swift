import SwiftUI

@main
struct NetworkSpeedBarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var settings = AppSettings.shared

    var body: some Scene {
        Settings {
            PreferencesView()
                .environmentObject(settings)
        }
    }
}
