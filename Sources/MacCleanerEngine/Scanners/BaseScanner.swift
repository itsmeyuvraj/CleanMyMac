import Foundation

public protocol JunkScanner: Sendable {
    var category: CleanCategory { get }
    func scan(progress: @Sendable @escaping (String, Double) -> Void) async -> [JunkItem]
}

public enum ScannerUtils {
    public static func calculateSizeAndSubItems(
        url: URL,
        maxSubItems: Int = 20,
        stopIfLargerThan: Int64? = nil
    ) -> (sizeBytes: Int64, itemCount: Int, subItems: [JunkSubItem]) {
        let fileManager = FileManager.default
        var totalSize: Int64 = 0
        var totalCount = 0
        var subItems: [JunkSubItem] = []

        var isDir: ObjCBool = false
        guard fileManager.fileExists(atPath: url.path, isDirectory: &isDir) else {
            return (0, 0, [])
        }

        if !isDir.boolValue {
            if let attrs = try? fileManager.attributesOfItem(atPath: url.path),
               let size = attrs[.size] as? Int64 {
                let sub = JunkSubItem(name: url.lastPathComponent, path: url, sizeBytes: size)
                return (size, 1, [sub])
            }
            return (0, 0, [])
        }

        guard let enumerator = fileManager.enumerator(
            at: url,
            includingPropertiesForKeys: [.fileSizeKey, .isDirectoryKey],
            options: [.skipsPackageDescendants]
        ) else {
            return (0, 0, [])
        }

        for case let itemURL as URL in enumerator {
            do {
                let values = try itemURL.resourceValues(forKeys: [.fileSizeKey, .isDirectoryKey])
                if values.isDirectory == false {
                    let size = Int64(values.fileSize ?? 0)
                    totalSize += size
                    totalCount += 1

                    if subItems.count < maxSubItems {
                        let sub = JunkSubItem(
                            name: itemURL.lastPathComponent,
                            path: itemURL,
                            sizeBytes: size,
                            isSelected: true
                        )
                        subItems.append(sub)
                    }

                    if let limit = stopIfLargerThan, totalSize > limit {
                        break
                    }
                }
            } catch {
                continue
            }
        }

        return (totalSize, totalCount, subItems)
    }

    public static func getFolderDirectChildren(url: URL) -> [URL] {
        let fileManager = FileManager.default
        guard let items = try? fileManager.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }
        return items
    }
}
