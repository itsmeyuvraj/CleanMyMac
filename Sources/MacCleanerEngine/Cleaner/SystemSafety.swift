import Foundation

public final class SystemSafety: Sendable {
    public static let shared = SystemSafety()

    private let protectedSystemPrefixes: [String] = [
        "/System",
        "/usr",
        "/bin",
        "/sbin",
        "/var/db",
        "/private/var/db",
        "/Library/Preferences/SystemConfiguration",
        "/Library/Extensions",
        "/Library/Audio/Plug-Ins",
        "/Library/Apple",
        "/Library/SystemExtensions"
    ]

    private let protectedUserSubpaths: [String] = [
        "Library/Keychains",
        "Library/Photos",
        "Library/IdentityServices",
        "Library/Accounts",
        "Library/Safari/Bookmarks.plist",
        "Documents",
        "Desktop",
        "Pictures",
        "Music",
        "Movies"
    ]

    private let systemWhitelistedKeywords: Set<String> = [
        "apple",
        "com.apple",
        "addressbook",
        "callhistory",
        "calendar",
        "clouddocs",
        "colorsync",
        "coredata",
        "crashreporter",
        "dock",
        "fileprovider",
        "finder",
        "fontcollections",
        "frontboard",
        "geoservices",
        "identityservices",
        "knowledge",
        "messages",
        "mobilesync",
        "passes",
        "photos",
        "quicklook",
        "quick look",
        "safari",
        "safarishared",
        "screensaver",
        "services",
        "sharing",
        "speech",
        "suggestions",
        "syncedpreferences",
        "touchbar",
        "virtualization",
        "voicetrigger",
        "weather",
        "accountsd",
        "callservicesd",
        "cloudd",
        "familycircled",
        "findmydeviced",
        "identityservicesd",
        "imagent",
        "mediaserverd",
        "parsecd",
        "studentd",
        "suggestd",
        "locationaccessstored",
        "homeenergyd",
        "networkserviceproxy",
        "diskimages",
        "animoji",
        "softwareupdate",
        "storekit",
        "commercekit",
        "accounts",
        "reminders",
        "spotlight",
        "metadata",
        "biome",
        "shortcuts",
        "siri",
        "coresuggestions",
        "intelligenceplatform",
        "universalcontrol",
        "sidecar",
        "airdrop",
        "passkit",
        "gamekit",
        "sharedimagecache",
        "tvapp_bag",
        "homekit",
        "healthkit",
        "eventkit",
        "webkit",
        "coreml",
        "coreaudio",
        "coremedia",
        "corebluetooth",
        "corewlan",
        "systemextensions",
        "securityagent",
        "cloudkit",
        "pushservice",
        "imfoundation",
        "coretelephony",
        "telemetrydeck",
        "sentry",
        "sentrycrash",
        "homebrew",
        "git",
        "gnupg",
        "ssh",
        "pip",
        "npm",
        "yarn",
        "cargo",
        "docker"
    ]

    public init() {}

    public func isSafeToDelete(url: URL) -> Bool {
        let path = url.standardized.path
        let home = NSHomeDirectory()

        // Root or user home directory cannot be deleted
        if path == "/" || path == home {
            return false
        }

        // Never touch core system directories
        for prefix in protectedSystemPrefixes {
            if path == prefix || path.hasPrefix(prefix + "/") {
                return false
            }
        }

        // Never touch protected user subpaths (Keychains, Photos, Documents, etc.)
        for subpath in protectedUserSubpaths {
            let fullProtected = (home as NSString).appendingPathComponent(subpath)
            if path == fullProtected || path.hasPrefix(fullProtected + "/") {
                return false
            }
        }

        return true
    }

    public func isSystemWhitelisted(name: String) -> Bool {
        let lower = name.lowercased()
        if lower.starts(with: "com.apple.") || lower.contains(".apple.") {
            return true
        }
        for keyword in systemWhitelistedKeywords {
            if lower == keyword || lower.contains(keyword) {
                return true
            }
        }
        return false
    }
}
