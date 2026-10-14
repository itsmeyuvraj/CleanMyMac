import Foundation

public struct CleanOptions: Sendable {
    public var deletePermanently: Bool
    public var isDryRun: Bool

    public init(deletePermanently: Bool = false, isDryRun: Bool = false) {
        self.deletePermanently = deletePermanently
        self.isDryRun = isDryRun
    }
}

public final class CleanEngine: Sendable {
    public static let shared = CleanEngine()

    public init() {}

    public func clean(
        items: [JunkItem],
        options: CleanOptions = CleanOptions(),
        progress: @Sendable @escaping (_ currentItem: String, _ progressRatio: Double, _ reclaimedSoFar: Int64) -> Void
    ) async -> CleanResult {
        let startTime = Date()
        var reclaimedBytes: Int64 = 0
        var itemsDeletedCount = 0
        var failedItems: [(path: String, reason: String)] = []

        let selectedItems = items.filter { $0.isSelected && !$0.isProtected }
        let totalCount = max(1, selectedItems.count)
        let safety = SystemSafety.shared
        let fileManager = FileManager.default

        for (index, item) in selectedItems.enumerated() {
            let ratio = Double(index) / Double(totalCount)
            progress(item.name, ratio, reclaimedBytes)

            // Safety check
            guard safety.isSafeToDelete(url: item.path) else {
                failedItems.append((path: item.path.path, reason: "Protected system path or file."))
                continue
            }

            if options.isDryRun {
                // Dry run mode - simulate deletion
                reclaimedBytes += item.sizeBytes
                itemsDeletedCount += 1
                try? await Task.sleep(nanoseconds: 20_000_000) // 20ms delay for simulation feel
                continue
            }

            // Real cleanup
            do {
                if item.path.lastPathComponent == ".Trash" {
                    // Empty contents of Trash
                    let trashItems = (try? fileManager.contentsOfDirectory(at: item.path, includingPropertiesForKeys: nil)) ?? []
                    for tItem in trashItems {
                        try? fileManager.removeItem(at: tItem)
                    }
                    reclaimedBytes += item.sizeBytes
                    itemsDeletedCount += item.itemCount
                } else if options.deletePermanently {
                    try fileManager.removeItem(at: item.path)
                    reclaimedBytes += item.sizeBytes
                    itemsDeletedCount += 1
                } else {
                    // Safe cleanup: Move to macOS Trash
                    var resultingURL: NSURL?
                    try fileManager.trashItem(at: item.path, resultingItemURL: &resultingURL)
                    reclaimedBytes += item.sizeBytes
                    itemsDeletedCount += 1
                }
            } catch {
                failedItems.append((path: item.path.path, reason: error.localizedDescription))
            }
        }

        let duration = Date().timeIntervalSince(startTime)
        progress("Cleanup completed!", 1.0, reclaimedBytes)

        return CleanResult(
            reclaimedBytes: reclaimedBytes,
            itemsDeletedCount: itemsDeletedCount,
            failedItems: failedItems,
            durationSeconds: duration
        )
    }
}
