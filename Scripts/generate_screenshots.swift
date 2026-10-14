import SwiftUI
import AppKit
import MacCleanerEngine

@MainActor
struct WindowWrapper<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 0) {
            // macOS Window Title Bar
            HStack(spacing: 8) {
                HStack(spacing: 8) {
                    Circle().fill(Color(red: 1.0, green: 0.38, blue: 0.34)).frame(width: 12, height: 12)
                    Circle().fill(Color(red: 1.0, green: 0.75, blue: 0.25)).frame(width: 12, height: 12)
                    Circle().fill(Color(red: 0.16, green: 0.78, blue: 0.33)).frame(width: 12, height: 12)
                }
                .padding(.leading, 16)

                Spacer()

                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.cyan)

                    Text(title)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                }

                Spacer()

                Color.clear.frame(width: 50, height: 12)
            }
            .frame(height: 38)
            .background(Color(red: 0.05, green: 0.06, blue: 0.10))

            Divider().background(Color.white.opacity(0.1))

            content
        }
        .frame(width: 1040, height: 700)
        .background(Theme.bgDeep)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.3), Color.cyan.opacity(0.2), Color.white.opacity(0.08)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
}

@main
struct ScreenshotGenerator {
    @MainActor
    static func main() async {
        let vm = CleanerViewModel()

        // Set realistic stats
        vm.diskStats = DiskStats(
            totalBytes: 245 * 1024 * 1024 * 1024,
            freeBytes: 126 * 1024 * 1024 * 1024,
            usedBytes: 119 * 1024 * 1024 * 1024
        )

        // Mock scanned items
        var items: [JunkItem] = []

        // Quick Cache
        items.append(JunkItem(
            name: "Google Chrome Web Cache",
            path: URL(fileURLWithPath: "/Users/yuvraj/Library/Caches/Google/Chrome"),
            sizeBytes: 1_420_000_000,
            itemCount: 4210,
            category: .quickCache,
            subCategory: "Web Browsers",
            isSelected: true,
            details: "Cached network responses, images, and session tabs."
        ))
        items.append(JunkItem(
            name: "Safari Web Cache",
            path: URL(fileURLWithPath: "/Users/yuvraj/Library/Caches/com.apple.Safari"),
            sizeBytes: 680_000_000,
            itemCount: 1840,
            category: .quickCache,
            subCategory: "Web Browsers",
            isSelected: true,
            details: "Cached stylesheets, scripts, and preloaded pages."
        ))
        items.append(JunkItem(
            name: "Spotify Audio & Artwork Cache",
            path: URL(fileURLWithPath: "/Users/yuvraj/Library/Caches/com.spotify.client"),
            sizeBytes: 520_000_000,
            itemCount: 890,
            category: .quickCache,
            subCategory: "Application Caches",
            isSelected: true,
            details: "Streaming song cache and album artwork previews."
        ))
        items.append(JunkItem(
            name: "Slack Messaging Cache",
            path: URL(fileURLWithPath: "/Users/yuvraj/Library/Caches/com.tinyspeck.slackmacgap"),
            sizeBytes: 340_000_000,
            itemCount: 1120,
            category: .quickCache,
            subCategory: "Messaging & Communication",
            isSelected: true,
            details: "Cached team avatars, emojis, and shared attachments."
        ))
        items.append(JunkItem(
            name: "Homebrew Downloads Cache",
            path: URL(fileURLWithPath: "/Users/yuvraj/Library/Caches/Homebrew"),
            sizeBytes: 410_000_000,
            itemCount: 15,
            category: .quickCache,
            subCategory: "Developer Tools",
            isSelected: true,
            details: "Cached formula bottles and tarballs."
        ))

        // Deep Clean
        items.append(JunkItem(
            name: "Xcode DerivedData",
            path: URL(fileURLWithPath: "/Users/yuvraj/Library/Developer/Xcode/DerivedData"),
            sizeBytes: 4_650_000_000,
            itemCount: 12400,
            category: .deepClean,
            subCategory: "Developer Junk",
            isSelected: true,
            details: "Intermediate build artifacts, indexes, and symbol stores."
        ))
        items.append(JunkItem(
            name: "iOS Simulator Caches",
            path: URL(fileURLWithPath: "/Users/yuvraj/Library/Developer/CoreSimulator/Caches"),
            sizeBytes: 2_100_000_000,
            itemCount: 3400,
            category: .deepClean,
            subCategory: "Developer Junk",
            isSelected: true,
            details: "Simulated runtime app states and sandbox caches."
        ))
        items.append(JunkItem(
            name: "System Diagnostic & Crash Reports",
            path: URL(fileURLWithPath: "/Users/yuvraj/Library/Logs/DiagnosticReports"),
            sizeBytes: 480_000_000,
            itemCount: 320,
            category: .deepClean,
            subCategory: "System Logs & Reports",
            isSelected: true,
            details: "Historical crash traces and system error dumps."
        ))
        items.append(JunkItem(
            name: "System Trash Bin",
            path: URL(fileURLWithPath: "/Users/yuvraj/.Trash"),
            sizeBytes: 1_920_000_000,
            itemCount: 48,
            category: .deepClean,
            subCategory: "Trash",
            isSelected: true,
            details: "Files currently stored in the macOS Trash."
        ))

        // App Leftovers
        items.append(JunkItem(
            name: "Digiarty (Uninstalled)",
            path: URL(fileURLWithPath: "/Users/yuvraj/Library/Application Support/Digiarty"),
            sizeBytes: 1_160_000_000,
            itemCount: 680,
            category: .appLeftovers,
            subCategory: "Uninstalled Application Residuals",
            isSelected: true,
            details: "Leftover media caches from uninstalled video tool.",
            associatedApp: "Digiarty"
        ))
        items.append(JunkItem(
            name: "Opera Software (Uninstalled)",
            path: URL(fileURLWithPath: "/Users/yuvraj/Library/Application Support/com.operasoftware.Opera"),
            sizeBytes: 380_000_000,
            itemCount: 240,
            category: .appLeftovers,
            subCategory: "Uninstalled Application Residuals",
            isSelected: true,
            details: "Residual user profile and extensions from uninstalled Opera.",
            associatedApp: "Opera"
        ))
        items.append(JunkItem(
            name: "ClipFlow (Uninstalled)",
            path: URL(fileURLWithPath: "/Users/yuvraj/Library/Application Support/com.yuvraj.clipflow"),
            sizeBytes: 140_000_000,
            itemCount: 110,
            category: .appLeftovers,
            subCategory: "Uninstalled Application Residuals",
            isSelected: true,
            details: "Residual clipboard database and cached previews.",
            associatedApp: "ClipFlow"
        ))
        items.append(JunkItem(
            name: "BlueJ (Uninstalled)",
            path: URL(fileURLWithPath: "/Users/yuvraj/Library/Preferences/org.bluej.BlueJ.plist"),
            sizeBytes: 85_000_000,
            itemCount: 12,
            category: .appLeftovers,
            subCategory: "Uninstalled Application Residuals",
            isSelected: true,
            details: "Leftover preferences and project state from uninstalled BlueJ.",
            associatedApp: "BlueJ"
        ))

        // Large Files
        items.append(JunkItem(
            name: "macOS_Sonoma_Install.dmg",
            path: URL(fileURLWithPath: "/Users/yuvraj/Downloads/macOS_Sonoma_Install.dmg"),
            sizeBytes: 13_500_000_000,
            itemCount: 1,
            category: .largeFiles,
            subCategory: "Disk Images & Installers",
            isSelected: true,
            details: "Downloads • Modified: 3 weeks ago"
        ))
        items.append(JunkItem(
            name: "Xcode_16_Beta.xip",
            path: URL(fileURLWithPath: "/Users/yuvraj/Downloads/Xcode_16_Beta.xip"),
            sizeBytes: 14_200_000_000,
            itemCount: 1,
            category: .largeFiles,
            subCategory: "Disk Images & Installers",
            isSelected: false,
            details: "Downloads • Modified: 1 month ago"
        ))

        vm.scanResult = ScanResult(items: items)

        // Render 1: Dashboard
        render(
            view: WindowWrapper(title: "MacCleaner — Smart Dashboard") {
                DashboardView(viewModel: vm)
            },
            names: ["dashboard.png"]
        )

        // Render 2: Uninstalled App Leftovers
        render(
            view: WindowWrapper(title: "MacCleaner — Uninstalled App Leftovers") {
                LeftoversView(viewModel: vm)
            },
            names: ["leftovers.png"]
        )

        // Render 3: Quick Clean
        render(
            view: WindowWrapper(title: "MacCleaner — 1-Click Quick Cache Clean") {
                QuickCleanView(viewModel: vm)
            },
            names: ["quickclean.png"]
        )

        // Render 4: Deep Clean
        render(
            view: WindowWrapper(title: "MacCleaner — Deep System Clean") {
                DeepCleanView(viewModel: vm)
            },
            names: ["deepclean.png"]
        )

        print("All screenshots generated successfully!")
    }

    @MainActor
    static func render<V: View>(view: V, names: [String]) {
        let renderer = ImageRenderer(content: view)
        renderer.scale = 2.0 // Crisp 2x Retina quality
        guard let nsImage = renderer.nsImage else {
            print("Failed to render view for:", names)
            return
        }

        guard let tiff = nsImage.tiffRepresentation,
              let rep = NSBitmapImageRep(data: tiff),
              let pngData = rep.representation(using: .png, properties: [:]) else {
            print("Failed to create PNG data for:", names)
            return
        }

        let outputDirs = ["Resources/Screenshots", "docs/screenshots"]
        for dir in outputDirs {
            for name in names {
                let url = URL(fileURLWithPath: "\(dir)/\(name)")
                try? pngData.write(to: url)
                print("Saved screenshot to:", url.path)
            }
        }
    }
}
