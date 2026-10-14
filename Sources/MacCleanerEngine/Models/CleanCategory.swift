import Foundation

public enum CleanCategory: String, CaseIterable, Identifiable, Sendable {
    case quickCache = "quickCache"
    case deepClean = "deepClean"
    case appLeftovers = "appLeftovers"
    case largeFiles = "largeFiles"

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .quickCache:
            return "Quick Cache Clean"
        case .deepClean:
            return "Deep System Clean"
        case .appLeftovers:
            return "App Leftovers"
        case .largeFiles:
            return "Large & Old Files"
        }
    }

    public var subtitle: String {
        switch self {
        case .quickCache:
            return "App caches, browser data, and temporary files safely cleared in 1 click."
        case .deepClean:
            return "System logs, crash reports, Xcode derived data, simulator files & Trash."
        case .appLeftovers:
            return "Orphaned files, caches, and preferences left behind by uninstalled apps."
        case .largeFiles:
            return "Unused DMG installers, large archives, and hefty downloads taking up space."
        }
    }

    public var iconName: String {
        switch self {
        case .quickCache:
            return "bolt.circle.fill"
        case .deepClean:
            return "sparkles.rectangle.stack.fill"
        case .appLeftovers:
            return "trash.slash.fill"
        case .largeFiles:
            return "shippingbox.fill"
        }
    }

    public var badgeColorHex: String {
        switch self {
        case .quickCache:
            return "007AFF" // System Blue
        case .deepClean:
            return "AF52DE" // Purple
        case .appLeftovers:
            return "FF9500" // Orange
        case .largeFiles:
            return "34C759" // Green
        }
    }
}
