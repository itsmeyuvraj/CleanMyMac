# MacCleaner 🚀
### Ultra-Fast, Native macOS System Cleaner & Uninstalled App Leftovers Remover

MacCleaner is a modern, high-performance native macOS cleaning utility built with **Swift 6** and **SwiftUI**. Designed specifically for Apple Silicon (M1/M2/M3/M4) and modern macOS. It provides **1-Click Cache Cleaning**, **Deep System Cleaning**, and intelligent detection of **Orphaned Leftover Files from Uninstalled Applications**.

---

## ✨ Key Features

### 1. ⚡ 1-Click Quick Cache Clean
- Purges user application caches (`~/Library/Caches`)
- Cleans browser caches (Google Chrome, Safari, Brave, Edge, Firefox)
- Cleans messaging app caches (Slack, Discord, Telegram, WhatsApp, Teams)
- Cleans macOS QuickLook thumbnails and temporary session data
- Reclaims gigabytes of disk space in a single click without affecting personal settings

### 2. 🧹 Deep System Clean
- **Developer Junk**: Xcode DerivedData, Simulator caches (`CoreSimulator`), iOS Device Support symbols, Gradle build cache, CocoaPods, NPM cache, Yarn cache
- **System Logs & Dumps**: Historical system log files (`~/Library/Logs`), crash dumps, and diagnostic reports (`DiagnosticReports`)
- **Residual States**: Saved application state (`Saved Application State`) from closed/crashed apps
- **Incomplete Downloads**: Broken or paused `.crdownload` and `.part` files
- **macOS Trash Bin**: Empties accumulated deleted items

### 3. 📦 Uninstalled App Leftovers (Orphan Cleaner)
- When you drag an app to the Trash on macOS, its supporting data remains behind!
- MacCleaner indexes all installed applications and compares them against:
  - `~/Library/Application Support/`
  - `~/Library/Caches/`
  - `~/Library/Preferences/` (`.plist` configuration files)
  - `~/Library/Saved Application State/`
  - `~/Library/Containers/` & `Group Containers`
  - `~/Library/WebKit/` & `HTTPStorages`
- Accurately detects folders and plists belonging to apps that are **no longer installed**
- Groups leftover files by application name with item count, total size, and **"Reveal in Finder"** verification

### 4. 🗄️ Large & Old Files Finder
- Locates forgotten `.dmg` installer disk images, `.pkg` files, and `.zip`/`.tar` archives in `Downloads` and `Desktop`
- Surfaces files larger than 100 MB for easy review

---

## 🛡️ Built-in Safety & Security

- **Safe Deletion by Default**: Cleaned items are moved to the **macOS Trash** (`FileManager.trashItem`), making every deletion safe and 100% recoverable with Finder's "Put Back" feature.
- **Strict Protection Whitelist**:
  - Personal folders (`Documents`, `Desktop`, `Pictures`, `Music`, `Movies`, `Photos`, `Keychains`) are **never touched**.
  - Apple system services and SIP directories (`/System`, `/usr`, `/Library/Preferences/SystemConfiguration`, `com.apple.*`, iCloud sync daemons) are protected.
- **Granular Control**: Every single file can be inspected, expanded, or deselected before cleaning.
- **Dry Run Mode**: Test scans and simulated cleanups without modifying files on disk.

---

## 🖥️ Launching the App

### Option A: Native GUI App
Double-click `MacCleaner.app` in Finder, or run from Terminal:
```bash
open MacCleaner.app
```
Or run the quick launcher:
```bash
./Scripts/run.sh
```

### Option B: Command-Line Interface (CLI)
A standalone CLI tool is included in `build/mac-cleaner`:

```bash
# Check Mac storage status
./build/mac-cleaner status

# Full system scan
./build/mac-cleaner scan

# 1-Click Cache Clean
./build/mac-cleaner quick-clean

# Deep clean developer junk, logs, and trash
./build/mac-cleaner deep-clean

# Clean leftovers from uninstalled apps
./build/mac-cleaner leftovers

# Clean all junk files across all categories
./build/mac-cleaner clean-all

# Simulation mode (does not delete any files)
./build/mac-cleaner leftovers --dry-run

# Bypass interactive confirmation prompt
./build/mac-cleaner quick-clean -y
```

---

## 🛠️ Rebuilding from Source

The project uses the standard Swift Package Manager and Xcode command line tools:

```bash
# Build MacCleaner.app and the CLI binary
./Scripts/build.sh
```

---

## 📁 Project Structure

```
Mac cleaner/
├── MacCleaner.app/                  # Compiled macOS Application Bundle
├── Package.swift                    # Swift Package Manager manifest
├── Sources/
│   ├── MacCleanerEngine/            # Core scanning & cleaning engine
│   │   ├── Models/                  # JunkItem, CleanCategory, SystemStats, ScanResult
│   │   ├── Scanners/                # CacheScanner, DeepCleanScanner, LeftoverScanner, LargeFilesScanner
│   │   ├── Cleaner/                 # CleanEngine, SystemSafety (whitelists)
│   │   └── System/                  # DiskManager, AppDiscovery
│   ├── MacCleanerApp/               # SwiftUI Native macOS GUI
│   │   ├── AppMain.swift            # App entry point
│   │   ├── ViewModels/              # CleanerViewModel (state & async tasks)
│   │   └── Views/                   # Dashboard, QuickClean, DeepClean, Leftovers, LargeFiles, Settings
│   └── MacCleanerCLI/               # Terminal tool (CLIMain.swift)
├── Resources/
│   ├── AppIcon.icns                 # High-resolution application icon
│   └── Info.plist                   # App metadata and bundle configuration
├── Scripts/
│   ├── build.sh                     # Automated release build & packaging script
│   ├── run.sh                       # Quick launch script
│   └── generate_icon.swift          # Programmatic icon generator
└── README.md
```
