import Foundation

public struct JunkSubItem: Identifiable, Sendable {
    public let id: UUID
    public let name: String
    public let path: URL
    public let sizeBytes: Int64
    public var isSelected: Bool

    public init(id: UUID = UUID(), name: String, path: URL, sizeBytes: Int64, isSelected: Bool = true) {
        self.id = id
        self.name = name
        self.path = path
        self.sizeBytes = sizeBytes
        self.isSelected = isSelected
    }

    public var formattedSize: String {
        ByteCountFormatter.string(fromByteCount: sizeBytes, countStyle: .file)
    }
}

public struct JunkItem: Identifiable, Sendable {
    public let id: UUID
    public let name: String
    public let path: URL
    public var sizeBytes: Int64
    public var itemCount: Int
    public let category: CleanCategory
    public let subCategory: String
    public var isSelected: Bool
    public let isProtected: Bool
    public let details: String
    public let associatedApp: String?
    public var subItems: [JunkSubItem]

    public init(
        id: UUID = UUID(),
        name: String,
        path: URL,
        sizeBytes: Int64,
        itemCount: Int = 1,
        category: CleanCategory,
        subCategory: String,
        isSelected: Bool = true,
        isProtected: Bool = false,
        details: String = "",
        associatedApp: String? = nil,
        subItems: [JunkSubItem] = []
    ) {
        self.id = id
        self.name = name
        self.path = path
        self.sizeBytes = sizeBytes
        self.itemCount = itemCount
        self.category = category
        self.subCategory = subCategory
        self.isSelected = isSelected
        self.isProtected = isProtected
        self.details = details
        self.associatedApp = associatedApp
        self.subItems = subItems
    }

    public var formattedSize: String {
        ByteCountFormatter.string(fromByteCount: sizeBytes, countStyle: .file)
    }
}
