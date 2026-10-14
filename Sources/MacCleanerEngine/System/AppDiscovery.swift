import Foundation

public struct InstalledAppsDatabase: Sendable {
    public let bundleIDs: Set<String>
    public let appNames: Set<String>
    public let normalizedNames: Set<String>
    public let appPaths: [URL]

    public func containsApp(identifierOrName: String) -> Bool {
        let lower = identifierOrName.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        if bundleIDs.contains(lower) { return true }
        if appNames.contains(lower) { return true }
        
        let normalized = lower.replacingOccurrences(of: "[^a-z0-9]", with: "", options: .regularExpression)
        if !normalized.isEmpty && normalizedNames.contains(normalized) { return true }

        // Check if any registered bundle ID contains or is contained in this identifier
        for bid in bundleIDs {
            if bid.hasSuffix("." + lower) || lower.hasSuffix("." + bid) {
                return true
            }
        }

        return false
    }
}

public final class AppDiscovery: Sendable {
    public static let shared = AppDiscovery()

    public init() {}

    public func discoverInstalledApps() -> InstalledAppsDatabase {
        var bundleIDs = Set<String>()
        var appNames = Set<String>()
        var normalizedNames = Set<String>()
        var appPaths = [URL]()

        let searchDirs: [String] = [
            "/Applications",
            "/Applications/Utilities",
            "/System/Applications",
            "/System/Applications/Utilities",
            "/System/Library/CoreServices",
            (NSHomeDirectory() as NSString).appendingPathComponent("Applications")
        ]

        let fileManager = FileManager.default

        for dirPath in searchDirs {
            let dirURL = URL(fileURLWithPath: dirPath)
            guard let enumerator = fileManager.enumerator(
                at: dirURL,
                includingPropertiesForKeys: [.isDirectoryKey],
                options: [.skipsHiddenFiles, .skipsPackageDescendants]
            ) else { continue }

            for case let fileURL as URL in enumerator {
                if fileURL.pathExtension.lowercased() == "app" {
                    appPaths.append(fileURL)
                    let baseName = fileURL.deletingPathExtension().lastPathComponent
                    let lowerName = baseName.lowercased()
                    appNames.insert(lowerName)
                    
                    let norm = lowerName.replacingOccurrences(of: "[^a-z0-9]", with: "", options: .regularExpression)
                    if !norm.isEmpty {
                        normalizedNames.insert(norm)
                    }

                    // Inspect Info.plist
                    let plistURL = fileURL.appendingPathComponent("Contents/Info.plist")
                    if let data = try? Data(contentsOf: plistURL),
                       let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any] {
                        if let bundleID = plist["CFBundleIdentifier"] as? String {
                            let bidLower = bundleID.lowercased()
                            bundleIDs.insert(bidLower)
                            let parts = bidLower.split(separator: ".")
                            if let last = parts.last {
                                appNames.insert(String(last))
                            }
                        }
                        if let cfName = plist["CFBundleName"] as? String {
                            let lower = cfName.lowercased()
                            appNames.insert(lower)
                            let norm = lower.replacingOccurrences(of: "[^a-z0-9]", with: "", options: .regularExpression)
                            if !norm.isEmpty { normalizedNames.insert(norm) }
                        }
                        if let dispName = plist["CFBundleDisplayName"] as? String {
                            let lower = dispName.lowercased()
                            appNames.insert(lower)
                            let norm = lower.replacingOccurrences(of: "[^a-z0-9]", with: "", options: .regularExpression)
                            if !norm.isEmpty { normalizedNames.insert(norm) }
                        }
                    }
                }
            }
        }

        // Also index system daemons and launch agents to avoid false positives
        let launchDirs = [
            "/System/Library/LaunchAgents",
            "/System/Library/LaunchDaemons",
            "/Library/LaunchAgents",
            "/Library/LaunchDaemons",
            (NSHomeDirectory() as NSString).appendingPathComponent("Library/LaunchAgents")
        ]

        for lDir in launchDirs {
            let lURL = URL(fileURLWithPath: lDir)
            if let items = try? fileManager.contentsOfDirectory(at: lURL, includingPropertiesForKeys: nil) {
                for item in items where item.pathExtension == "plist" {
                    let name = item.deletingPathExtension().lastPathComponent.lowercased()
                    bundleIDs.insert(name)
                    if let last = name.split(separator: ".").last {
                        appNames.insert(String(last))
                    }
                }
            }
        }

        return InstalledAppsDatabase(
            bundleIDs: bundleIDs,
            appNames: appNames,
            normalizedNames: normalizedNames,
            appPaths: appPaths
        )
    }
}
