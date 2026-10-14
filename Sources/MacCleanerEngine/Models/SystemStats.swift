import Foundation

public struct DiskStats: Sendable {
    public let totalBytes: Int64
    public let freeBytes: Int64
    public let usedBytes: Int64

    public init(totalBytes: Int64, freeBytes: Int64, usedBytes: Int64) {
        self.totalBytes = totalBytes
        self.freeBytes = freeBytes
        self.usedBytes = usedBytes
    }

    public var usedPercentage: Double {
        guard totalBytes > 0 else { return 0 }
        return Double(usedBytes) / Double(totalBytes)
    }

    public var freePercentage: Double {
        guard totalBytes > 0 else { return 0 }
        return Double(freeBytes) / Double(totalBytes)
    }

    public var formattedTotal: String {
        ByteCountFormatter.string(fromByteCount: totalBytes, countStyle: .file)
    }

    public var formattedFree: String {
        ByteCountFormatter.string(fromByteCount: freeBytes, countStyle: .file)
    }

    public var formattedUsed: String {
        ByteCountFormatter.string(fromByteCount: usedBytes, countStyle: .file)
    }
}

public struct CleanResult: Sendable {
    public let reclaimedBytes: Int64
    public let itemsDeletedCount: Int
    public let failedItems: [(path: String, reason: String)]
    public let durationSeconds: Double

    public init(
        reclaimedBytes: Int64 = 0,
        itemsDeletedCount: Int = 0,
        failedItems: [(path: String, reason: String)] = [],
        durationSeconds: Double = 0.0
    ) {
        self.reclaimedBytes = reclaimedBytes
        self.itemsDeletedCount = itemsDeletedCount
        self.failedItems = failedItems
        self.durationSeconds = durationSeconds
    }

    public var formattedReclaimed: String {
        ByteCountFormatter.string(fromByteCount: reclaimedBytes, countStyle: .file)
    }
}
