import SwiftUI
import AppKit

@main
struct MacCleanerApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
                .preferredColorScheme(.dark)
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified(showsTitle: false))
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("About MacCleaner") {
                    NSApplication.shared.orderFrontStandardAboutPanel(
                        options: [
                            NSApplication.AboutPanelOptionKey.applicationName: "MacCleaner",
                            NSApplication.AboutPanelOptionKey.version: "2.0.0",
                            NSApplication.AboutPanelOptionKey(rawValue: "Copyright"): "MacCleaner for macOS"
                        ]
                    )
                }
            }
        }
    }
}
