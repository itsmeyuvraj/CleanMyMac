import Foundation

public final class LargeFilesScanner: JunkScanner, Sendable {
    public let category: CleanCategory = .largeFiles

    public init() {}

    public func scan(progress: @Sendable @escaping (String, Double) -> Void) async -> [JunkItem] {
        var items: [JunkItem] = []
        let home = NSHomeDirectory()
        let fileManager = FileManager.default

        progress("Scanning Downloads & Desktop for large installers & archives...", 0.2)

        let targetDirs = [
            (path: (home as NSString).appendingPathComponent("Downloads"), label: "Downloads"),
            (path: (home as NSString).appendingPathComponent("Desktop"), label: "Desktop")
        ]

        let largeThreshold: Int64 = 100 * 1024 * 1024 // 100 MB

        for (dirIndex, target) in targetDirs.enumerated() {
            let dirURL = URL(fileURLWithPath: target.path)
            guard let contents = try? fileManager.contentsOfDirectory(
                at: dirURL,
                includingPropertiesForKeys: [.fileSizeKey, .contentModificationDateKey, .isDirectoryKey],
                options: [.skipsHiddenFiles]
            ) else { continue }

            let totalFiles = Double(contents.count)
            for (fileIdx, fileURL) in contents.enumerated() {
                let pct = 0.2 + (Double(dirIndex) * 0.4) + (Double(fileIdx) / max(1.0, totalFiles)) * 0.3
                progress("Checking \(fileURL.lastPathComponent)...", pct)

                let ext = fileURL.pathExtension.lowercased()
                let isInstallerOrArchive = ["dmg", "pkg", "iso", "zip", "tar", "gz", "xz", "7z", "rar"].contains(ext)

                guard let values = try? fileURL.resourceValues(forKeys: [.fileSizeKey, .isDirectoryKey, .contentModificationDateKey]),
                      values.isDirectory == false,
                      let size = values.fileSize else { continue }

                let size64 = Int64(size)

                // Surface if it is an installer/archive > 20MB, or any general file > 100MB
                if (isInstallerOrArchive && size64 > 20 * 1024 * 1024) || size64 > largeThreshold {
                    let sub = JunkSubItem(name: fileURL.lastPathComponent, path: fileURL, sizeBytes: size64)
                    let modDate = values.contentModificationDate ?? Date()
                    let dateStr = DateFormatter.localizedString(from: modDate, dateStyle: .medium, timeStyle: .none)

                    let item = JunkItem(
                        name: fileURL.lastPathComponent,
                        path: fileURL,
                        sizeBytes: size64,
                        itemCount: 1,
                        category: .largeFiles,
                        subCategory: isInstallerOrArchive ? "Disk Images & Installers" : "Large Files",
                        isSelected: isInstallerOrArchive, // Select DMG/PKG by default, deselect general files
                        details: "\(target.label) • Modified: \(dateStr)",
                        associatedApp: nil,
                        subItems: [sub]
                    )
                    items.append(item)
                }
            }
        }

        items.sort { $0.sizeBytes > $1.sizeBytes }
        progress("Large files scan complete.", 1.0)
        return items
    }
}
