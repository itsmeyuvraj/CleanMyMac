// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MacCleaner",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "MacCleanerApp", targets: ["MacCleanerApp"]),
        .executable(name: "mac-cleaner", targets: ["MacCleanerCLI"]),
        .library(name: "MacCleanerEngine", targets: ["MacCleanerEngine"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "MacCleanerEngine",
            dependencies: [],
            path: "Sources/MacCleanerEngine"
        ),
        .executableTarget(
            name: "MacCleanerApp",
            dependencies: ["MacCleanerEngine"],
            path: "Sources/MacCleanerApp"
        ),
        .executableTarget(
            name: "MacCleanerCLI",
            dependencies: ["MacCleanerEngine"],
            path: "Sources/MacCleanerCLI"
        )
    ]
)
