import Foundation
import MacCleanerEngine

@main
struct CLIMain {
    static func main() async {
        let args = CommandLine.arguments

        if args.count < 2 || args.contains("--help") || args.contains("-h") {
            printUsage()
            return
        }

        let command = args[1].lowercased()
        let isDryRun = args.contains("--dry-run")
        let isPermanent = args.contains("--permanent")
        let autoConfirm = args.contains("-y") || args.contains("--yes")

        let options = CleanOptions(deletePermanently: isPermanent, isDryRun: isDryRun)

        switch command {
        case "status":
            showDiskStatus()

        case "scan":
            await runScanReport()

        case "quick-clean":
            await runSpecificClean(category: .quickCache, options: options, autoConfirm: autoConfirm)

        case "deep-clean":
            await runSpecificClean(category: .deepClean, options: options, autoConfirm: autoConfirm)

        case "leftovers":
            await runSpecificClean(category: .appLeftovers, options: options, autoConfirm: autoConfirm)

        case "large-files":
            await runSpecificClean(category: .largeFiles, options: options, autoConfirm: autoConfirm)

        case "clean-all":
            await runCleanAll(options: options, autoConfirm: autoConfirm)

        default:
            print("\u{001B}[31mUnknown command: \(command)\u{001B}[0m")
            printUsage()
        }
    }

    static func showDiskStatus() {
        let stats = DiskManager.shared.getDiskStats()
        print("\n\u{001B}[1;36m=== Mac Storage Status ===\u{001B}[0m")
        print("Total Capacity : \(stats.formattedTotal)")
        print("Used Space     : \(stats.formattedUsed) (\(String(format: "%.1f", stats.usedPercentage * 100))%)")
        print("Free Space     : \(stats.formattedFree) (\(String(format: "%.1f", stats.freePercentage * 100))%)")
        print("===========================\n")
    }

    static func runScanReport() async {
        print("\n\u{001B}[1;35mScanning your Mac for junk files and app leftovers...\u{001B}[0m")

        let scanners: [any JunkScanner] = [
            CacheScanner(),
            DeepCleanScanner(),
            LeftoverScanner(),
            LargeFilesScanner()
        ]

        var allItems: [JunkItem] = []

        for scanner in scanners {
            print("\u{001B}[33m• Scanning \(scanner.category.title)...\u{001B}[0m")
            let items = await scanner.scan { current, pct in
                // Progress
            }
            let size = items.reduce(0) { $0 + $1.sizeBytes }
            let formatted = ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
            print("  Found \(items.count) items (\(formatted))")
            allItems.append(contentsOf: items)
        }

        let totalSize = allItems.reduce(0) { $0 + $1.sizeBytes }
        let formattedTotal = ByteCountFormatter.string(fromByteCount: totalSize, countStyle: .file)

        print("\n\u{001B}[1;32m====================================================\u{001B}[0m")
        print("\u{001B}[1;32mTotal Reclaimable Space: \(formattedTotal) in \(allItems.count) items\u{001B}[0m")
        print("\u{001B}[1;32m====================================================\u{001B}[0m\n")
    }

    static func runSpecificClean(category: CleanCategory, options: CleanOptions, autoConfirm: Bool) async {
        print("\n\u{001B}[1;34mScanning for \(category.title)...\u{001B}[0m")

        let scanner: any JunkScanner
        switch category {
        case .quickCache: scanner = CacheScanner()
        case .deepClean: scanner = DeepCleanScanner()
        case .appLeftovers: scanner = LeftoverScanner()
        case .largeFiles: scanner = LargeFilesScanner()
        }

        let items = await scanner.scan { _, _ in }
        let totalSize = items.reduce(0) { $0 + $1.sizeBytes }
        let formatted = ByteCountFormatter.string(fromByteCount: totalSize, countStyle: .file)

        if items.isEmpty || totalSize == 0 {
            print("\u{001B}[32m✓ No \(category.title) junk found. Your Mac is already clean!\u{001B}[0m\n")
            return
        }

        print("\u{001B}[1mFound \(items.count) items taking \(formatted):\u{001B}[0m")
        for item in items.prefix(15) {
            print("  • \(item.name) (\(item.formattedSize))")
        }
        if items.count > 15 {
            print("  ... and \(items.count - 15) more items")
        }

        if !autoConfirm && !options.isDryRun {
            print("\nProceed with cleaning \(formatted)? (y/N): ", terminator: "")
            let response = readLine()?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            if response != "y" && response != "yes" {
                print("Cancelled.")
                return
            }
        }

        print("\nCleaning \(category.title)...")
        let result = await CleanEngine.shared.clean(items: items, options: options) { name, pct, reclaimed in
            let rFormatted = ByteCountFormatter.string(fromByteCount: reclaimed, countStyle: .file)
            print("[\(Int(pct * 100))%] Reclaimed \(rFormatted) - \(name)")
        }

        print("\n\u{001B}[1;32m✓ Successfully cleaned \(result.formattedReclaimed) in \(result.itemsDeletedCount) items!\u{001B}[0m")
        if !result.failedItems.isEmpty {
            print("\u{001B}[33m(\(result.failedItems.count) locked items skipped)\u{001B}[0m")
        }
        print("")
    }

    static func runCleanAll(options: CleanOptions, autoConfirm: Bool) async {
        print("\n\u{001B}[1;35mInitiating Full Mac Deep Clean...\u{001B}[0m")

        let scanners: [any JunkScanner] = [
            CacheScanner(),
            DeepCleanScanner(),
            LeftoverScanner(),
            LargeFilesScanner()
        ]

        var allItems: [JunkItem] = []
        for scanner in scanners {
            let items = await scanner.scan { _, _ in }
            allItems.append(contentsOf: items)
        }

        let totalSize = allItems.reduce(0) { $0 + $1.sizeBytes }
        let formatted = ByteCountFormatter.string(fromByteCount: totalSize, countStyle: .file)

        if allItems.isEmpty || totalSize == 0 {
            print("\u{001B}[32m✓ Nothing to clean. Your Mac is in top shape!\u{001B}[0m\n")
            return
        }

        print("\nFound \(allItems.count) cleanable items totaling \(formatted).")

        if !autoConfirm && !options.isDryRun {
            print("Do you want to clean all of them? (y/N): ", terminator: "")
            let response = readLine()?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            if response != "y" && response != "yes" {
                print("Cancelled.")
                return
            }
        }

        let result = await CleanEngine.shared.clean(items: allItems, options: options) { name, pct, reclaimed in
            let rFormatted = ByteCountFormatter.string(fromByteCount: reclaimed, countStyle: .file)
            print("[\(Int(pct * 100))%] Reclaimed \(rFormatted) - \(name)")
        }

        print("\n\u{001B}[1;32m✓ Clean complete! Freed \(result.formattedReclaimed) from your Mac.\u{001B}[0m\n")
    }

    static func printUsage() {
        print("""

\u{001B}[1;36mMacCleaner CLI\u{001B}[0m - High Performance macOS Cleaner & Leftovers Remover

\u{001B}[1mUSAGE:\u{001B}[0m
  mac-cleaner <command> [options]

\u{001B}[1mCOMMANDS:\u{001B}[0m
  status        Display Mac disk storage capacity and usage stats
  scan          Perform a full system scan and display reclaimable disk space
  quick-clean   1-Click clean of user caches, browser data, and temp files
  deep-clean    Deep clean logs, developer junk (Xcode), simulators, and Trash
  leftovers     Clean leftover files and orphaned caches from uninstalled apps
  large-files   Find and clean unused DMGs, installers, and large archives
  clean-all     Execute full sweep across all categories

\u{001B}[1mOPTIONS:\u{001B}[0m
  --dry-run     Simulate scan and clean without deleting any files
  --permanent   Permanently delete files instead of moving to Trash (default: safe Trash)
  -y, --yes     Bypass interactive confirmation prompt
  -h, --help    Show this help message

""")
    }
}
