import Foundation
import SwiftUI
import AppKit
import MacCleanerEngine

public enum NavigationSection: String, CaseIterable, Identifiable {
    case dashboard = "dashboard"
    case quickCache = "quickCache"
    case deepClean = "deepClean"
    case appLeftovers = "appLeftovers"
    case largeFiles = "largeFiles"
    case settings = "settings"

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .dashboard: return "Smart Dashboard"
        case .quickCache: return "Quick Cache Clean"
        case .deepClean: return "Deep Clean"
        case .appLeftovers: return "App Leftovers"
        case .largeFiles: return "Large Files"
        case .settings: return "Settings & Safety"
        }
    }

    public var iconName: String {
        switch self {
        case .dashboard: return "gauge.with.needle.fill"
        case .quickCache: return "bolt.fill"
        case .deepClean: return "sparkles.rectangle.stack.fill"
        case .appLeftovers: return "trash.slash.fill"
        case .largeFiles: return "shippingbox.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

@MainActor
public final class CleanerViewModel: ObservableObject {
    @Published public var selectedSection: NavigationSection = .dashboard
    @Published public var diskStats: DiskStats = DiskStats(totalBytes: 0, freeBytes: 0, usedBytes: 0)
    @Published public var scanResult: ScanResult = ScanResult()

    @Published public var isScanning: Bool = false
    @Published public var isCleaning: Bool = false
    @Published public var scanProgressText: String = "Ready to scan"
    @Published public var scanProgressValue: Double = 0.0

    @Published public var cleanProgressText: String = ""
    @Published public var cleanProgressValue: Double = 0.0
    @Published public var lastCleanResult: CleanResult? = nil
    @Published public var showSuccessCelebration: Bool = false

    @Published public var moveToTrashOnly: Bool = true
    @Published public var dryRunMode: Bool = false
    @Published public var searchQuery: String = ""

    private let scanners: [CleanCategory: any JunkScanner] = [
        .quickCache: CacheScanner(),
        .deepClean: DeepCleanScanner(),
        .appLeftovers: LeftoverScanner(),
        .largeFiles: LargeFilesScanner()
    ]

    public init() {
        refreshDiskStats()
    }

    public func refreshDiskStats() {
        self.diskStats = DiskManager.shared.getDiskStats()
    }

    public func startFullScan() {
        guard !isScanning && !isCleaning else { return }
        isScanning = true
        scanProgressValue = 0.0
        scanProgressText = "Preparing system scan..."

        Task {
            var combinedItems: [JunkItem] = []
            let totalScanners = Double(self.scanners.count)

            for (idx, (_, scanner)) in self.scanners.enumerated() {
                let startPct = Double(idx) / totalScanners
                let span = 1.0 / totalScanners

                let items = await scanner.scan { currentText, subPct in
                    Task { @MainActor in
                        self.scanProgressText = currentText
                        self.scanProgressValue = startPct + (subPct * span)
                    }
                }
                combinedItems.append(contentsOf: items)
            }

            self.scanResult = ScanResult(items: combinedItems)
            self.refreshDiskStats()
            self.scanProgressValue = 1.0
            self.scanProgressText = "Scan complete. Found \(self.scanResult.formattedTotalSize) junk."
            self.isScanning = false
        }
    }

    public func scanSingleCategory(_ category: CleanCategory) {
        guard !isScanning && !isCleaning, let scanner = scanners[category] else { return }
        isScanning = true
        scanProgressValue = 0.0
        scanProgressText = "Scanning \(category.title)..."

        Task {
            let items = await scanner.scan { text, pct in
                Task { @MainActor in
                    self.scanProgressText = text
                    self.scanProgressValue = pct
                }
            }

            // Replace items in this category
            var current = self.scanResult.items.filter { $0.category != category }
            current.append(contentsOf: items)
            self.scanResult = ScanResult(items: current)
            self.refreshDiskStats()
            self.scanProgressValue = 1.0
            self.scanProgressText = "\(category.title) scan complete."
            self.isScanning = false
        }
    }

    public func cleanSelectedItems(for category: CleanCategory? = nil) {
        guard !isCleaning && !isScanning else { return }

        let targetItems: [JunkItem]
        if let cat = category {
            targetItems = scanResult.items(for: cat).filter(\.isSelected)
        } else {
            targetItems = scanResult.items.filter(\.isSelected)
        }

        guard !targetItems.isEmpty else { return }

        isCleaning = true
        cleanProgressValue = 0.0
        cleanProgressText = "Starting cleanup..."

        let options = CleanOptions(
            deletePermanently: !moveToTrashOnly,
            isDryRun: dryRunMode
        )

        Task {
            let result = await CleanEngine.shared.clean(items: targetItems, options: options) { currentItem, ratio, reclaimed in
                Task { @MainActor in
                    self.cleanProgressText = "Cleaning \(currentItem)..."
                    self.cleanProgressValue = ratio
                }
            }

            // Remove cleaned items from scanResult
            let cleanedIDs = Set(targetItems.map(\.id))
            self.scanResult.items.removeAll { cleanedIDs.contains($0.id) }

            self.lastCleanResult = result
            self.refreshDiskStats()
            self.cleanProgressValue = 1.0
            self.cleanProgressText = "Cleaned \(result.formattedReclaimed)!"
            self.isCleaning = false
            self.showSuccessCelebration = true
        }
    }

    public func toggleItemSelection(id: UUID) {
        if let idx = scanResult.items.firstIndex(where: { $0.id == id }) {
            scanResult.items[idx].isSelected.toggle()
        }
    }

    public func setAllSelection(for category: CleanCategory, isSelected: Bool) {
        for idx in scanResult.items.indices where scanResult.items[idx].category == category {
            scanResult.items[idx].isSelected = isSelected
        }
    }

    public func revealInFinder(url: URL) {
        NSWorkspace.shared.selectFile(url.path, inFileViewerRootedAtPath: url.deletingLastPathComponent().path)
    }
}
