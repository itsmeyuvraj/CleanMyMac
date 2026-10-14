import Foundation

public final class LeftoverScanner: JunkScanner, Sendable {
    public let category: CleanCategory = .appLeftovers

    public init() {}

    public func scan(progress: @Sendable @escaping (String, Double) -> Void) async -> [JunkItem] {
        progress("Indexing installed applications on your Mac...", 0.1)

        let appDb = AppDiscovery.shared.discoverInstalledApps()
        let safety = SystemSafety.shared
        let fileManager = FileManager.default
        let home = NSHomeDirectory()

        progress("Scanning library for orphaned application files...", 0.3)

        // Locations where uninstalled apps leave residual traces
        let candidateLocations: [(subpath: String, typeName: String)] = [
            ("Library/Application Support", "Application Support"),
            ("Library/Caches", "Caches"),
            ("Library/Saved Application State", "Saved State"),
            ("Library/WebKit", "WebKit Data"),
            ("Library/HTTPStorages", "HTTP Storage"),
            ("Library/Containers", "App Sandboxes"),
            ("Library/Group Containers", "Group Containers")
        ]

        // Group leftovers by Application Name
        var leftoversByApp: [String: (paths: [URL], totalSize: Int64, count: Int, subItems: [JunkSubItem])] = [:]

        let totalLocs = Double(candidateLocations.count)

        for (locIdx, candidate) in candidateLocations.enumerated() {
            let locURL = URL(fileURLWithPath: (home as NSString).appendingPathComponent(candidate.subpath))
            let baseProgress = 0.3 + (Double(locIdx) / totalLocs) * 0.5
            progress("Checking \(candidate.typeName)...", baseProgress)

            guard let items = try? fileManager.contentsOfDirectory(
                at: locURL,
                includingPropertiesForKeys: [.isDirectoryKey],
                options: [.skipsHiddenFiles]
            ) else { continue }

            for itemURL in items {
                let folderName = itemURL.lastPathComponent

                // Skip generic or single letter folders
                if folderName.count <= 2 || folderName.lowercased() == NSUserName().lowercased() || ["default", "group", "categories"].contains(folderName.lowercased()) {
                    continue
                }

                // 1. Safety check
                if safety.isSystemWhitelisted(name: folderName) {
                    continue
                }

                // 2. Installed App check
                if appDb.containsApp(identifierOrName: folderName) {
                    continue
                }

                // Clean the app name for presentation
                let cleanedAppName = extractCleanAppName(from: folderName)

                // Skip if the cleaned name matches an installed app
                if appDb.containsApp(identifierOrName: cleanedAppName) {
                    continue
                }

                // 3. Calculate size
                let (size, count, subs) = ScannerUtils.calculateSizeAndSubItems(url: itemURL)

                // Skip negligible empty entries (< 16 KB)
                if size < 16 * 1024 && count == 0 {
                    continue
                }

                if var existing = leftoversByApp[cleanedAppName] {
                    existing.paths.append(itemURL)
                    existing.totalSize += size
                    existing.count += count
                    existing.subItems.append(contentsOf: subs)
                    leftoversByApp[cleanedAppName] = existing
                } else {
                    leftoversByApp[cleanedAppName] = ([itemURL], size, count, subs)
                }
            }
        }

        // Also check Preferences for orphaned .plist files
        progress("Checking orphaned Preferences plists...", 0.85)
        let prefsURL = URL(fileURLWithPath: (home as NSString).appendingPathComponent("Library/Preferences"))
        if let plists = try? fileManager.contentsOfDirectory(at: prefsURL, includingPropertiesForKeys: [.fileSizeKey], options: [.skipsHiddenFiles]) {
            for plistURL in plists where plistURL.pathExtension == "plist" {
                let baseName = plistURL.deletingPathExtension().lastPathComponent
                if safety.isSystemWhitelisted(name: baseName) { continue }
                if appDb.containsApp(identifierOrName: baseName) { continue }

                let cleaned = extractCleanAppName(from: baseName)
                if appDb.containsApp(identifierOrName: cleaned) { continue }

                if let values = try? plistURL.resourceValues(forKeys: [.fileSizeKey]),
                   let size = values.fileSize {
                    let sub = JunkSubItem(name: plistURL.lastPathComponent, path: plistURL, sizeBytes: Int64(size))
                    if var existing = leftoversByApp[cleaned] {
                        existing.paths.append(plistURL)
                        existing.totalSize += Int64(size)
                        existing.count += 1
                        existing.subItems.append(sub)
                        leftoversByApp[cleaned] = existing
                    } else {
                        leftoversByApp[cleaned] = ([plistURL], Int64(size), 1, [sub])
                    }
                }
            }
        }

        // Convert grouped items to JunkItem models
        var resultItems: [JunkItem] = []
        for (appName, data) in leftoversByApp {
            guard let primaryURL = data.paths.first else { continue }

            let item = JunkItem(
                name: "\(appName) (Uninstalled)",
                path: primaryURL,
                sizeBytes: data.totalSize,
                itemCount: data.count,
                category: .appLeftovers,
                subCategory: "Uninstalled Application Residuals",
                isSelected: true,
                details: "Leftover data from \(appName), which is no longer installed on your Mac.",
                associatedApp: appName,
                subItems: data.subItems
            )
            resultItems.append(item)
        }

        resultItems.sort { $0.sizeBytes > $1.sizeBytes }
        progress("App leftovers scan complete.", 1.0)
        return resultItems
    }

    private func extractCleanAppName(from rawIdentifier: String) -> String {
        // e.g. "com.yuvraj.clipflow" -> "Clipflow"
        // e.g. "org.videolan.vlc" -> "VLC"
        // e.g. "com.spotify.client" -> "Spotify"
        // e.g. "us.zoom.xos" -> "Zoom"
        var clean = rawIdentifier
        if clean.hasSuffix(".savedState") {
            clean = String(clean.dropLast(".savedState".count))
        }
        if clean.hasSuffix(".plist") {
            clean = String(clean.dropLast(".plist".count))
        }

        let parts = clean.split(separator: ".")
        if parts.count >= 2 {
            let filtered = parts.filter { !["com", "org", "net", "io", "app", "mac", "savedstate", "client"].contains($0.lowercased()) }
            if let lastMeaningful = filtered.last {
                return lastMeaningful.capitalized
            }
        }
        return clean
    }
}
