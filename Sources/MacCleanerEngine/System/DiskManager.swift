import Foundation

public final class DiskManager: Sendable {
    public static let shared = DiskManager()

    public init() {}

    public func getDiskStats() -> DiskStats {
        let homeURL = URL(fileURLWithPath: NSHomeDirectory())
        do {
            let values = try homeURL.resourceValues(forKeys: [
                .volumeTotalCapacityKey,
                .volumeAvailableCapacityKey,
                .volumeAvailableCapacityForImportantUsageKey
            ])

            let total = Int64(values.volumeTotalCapacity ?? 0)
            let free = values.volumeAvailableCapacityForImportantUsage ?? Int64(values.volumeAvailableCapacity ?? 0)
            let used = max(0, total - free)

            return DiskStats(totalBytes: total, freeBytes: free, usedBytes: used)
        } catch {
            // Fallback via statvfs
            var stats = statvfs()
            if statvfs("/", &stats) == 0 {
                let total = Int64(stats.f_frsize) * Int64(stats.f_blocks)
                let free = Int64(stats.f_frsize) * Int64(stats.f_bavail)
                let used = max(0, total - free)
                return DiskStats(totalBytes: total, freeBytes: free, usedBytes: used)
            }
            return DiskStats(totalBytes: 0, freeBytes: 0, usedBytes: 0)
        }
    }
}
