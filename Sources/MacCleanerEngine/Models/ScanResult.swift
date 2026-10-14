import Foundation

public struct ScanResult: Sendable {
    public let timestamp: Date
    public var items: [JunkItem]

    public init(timestamp: Date = Date(), items: [JunkItem] = []) {
        self.timestamp = timestamp
        self.items = items
    }

    public var totalBytes: Int64 {
        items.reduce(0) { $0 + $1.sizeBytes }
    }

    public var selectedBytes: Int64 {
        items.filter(\.isSelected).reduce(0) { $0 + $1.sizeBytes }
    }

    public var formattedTotalSize: String {
        ByteCountFormatter.string(fromByteCount: totalBytes, countStyle: .file)
    }

    public var formattedSelectedSize: String {
        ByteCountFormatter.string(fromByteCount: selectedBytes, countStyle: .file)
    }

    public func items(for category: CleanCategory) -> [JunkItem] {
        items.filter { $0.category == category }
    }

    public func size(for category: CleanCategory) -> Int64 {
        items(for: category).reduce(0) { $0 + $1.sizeBytes }
    }

    public func selectedSize(for category: CleanCategory) -> Int64 {
        items(for: category).filter(\.isSelected).reduce(0) { $0 + $1.sizeBytes }
    }

    public func formattedSize(for category: CleanCategory) -> String {
        ByteCountFormatter.string(fromByteCount: size(for: category), countStyle: .file)
    }

    public func itemCount(for category: CleanCategory) -> Int {
        items(for: category).count
    }
}
