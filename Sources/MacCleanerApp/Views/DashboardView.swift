import SwiftUI
import MacCleanerEngine

public struct DashboardView: View {
    @ObservedObject public var viewModel: CleanerViewModel

    public init(viewModel: CleanerViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                // HERO STORAGE REACTOR CARD
                HStack(spacing: 36) {
                    StorageRingView(
                        stats: viewModel.diskStats,
                        reclaimableBytes: viewModel.scanResult.totalBytes,
                        isScanning: viewModel.isScanning
                    )

                    VStack(alignment: .leading, spacing: 18) {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(viewModel.scanResult.totalBytes > 0 ? Color.orange : Color.green)
                                    .frame(width: 8, height: 8)
                                    .shadow(color: viewModel.scanResult.totalBytes > 0 ? .orange : .green, radius: 4)

                                Text(viewModel.scanResult.totalBytes > 0 ? "OPTIMIZATION RECOMMENDED" : "SYSTEM IN TOP SHAPE")
                                    .font(.system(size: 11, weight: .black, design: .rounded))
                                    .tracking(1.2)
                                    .foregroundColor(viewModel.scanResult.totalBytes > 0 ? Color.orange : Color.green)
                            }

                            Text("Clean & Optimize Mac")
                                .font(.system(size: 32, weight: .heavy, design: .rounded))
                                .foregroundColor(.white)

                            Text("Deep cleanse user caches, Xcode junk, and orphaned uninstalled app files.")
                                .font(.system(size: 13))
                                .foregroundColor(.white.opacity(0.6))
                        }

                        // Storage Metrics Bar
                        HStack(spacing: 20) {
                            MetricPill(title: "TOTAL CAPACITY", value: viewModel.diskStats.formattedTotal, dotColor: .white.opacity(0.4))
                            Divider().background(Color.white.opacity(0.1)).frame(height: 28)
                            MetricPill(title: "USED SPACE", value: viewModel.diskStats.formattedUsed, dotColor: .cyan)
                            Divider().background(Color.white.opacity(0.1)).frame(height: 28)
                            MetricPill(title: "AVAILABLE", value: viewModel.diskStats.formattedFree, dotColor: Color(red: 0.1, green: 0.9, blue: 0.5))
                        }
                        .padding(.vertical, 2)

                        // Action Buttons
                        HStack(spacing: 14) {
                            // Scan Button
                            Button {
                                viewModel.startFullScan()
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: viewModel.isScanning ? "arrow.triangle.2.circlepath" : "magnifyingglass")
                                        .rotationEffect(.degrees(viewModel.isScanning ? 360 : 0))
                                        .animation(viewModel.isScanning ? .linear(duration: 1).repeatForever(autoreverses: false) : .default, value: viewModel.isScanning)

                                    Text(viewModel.isScanning ? "Scanning Mac..." : "Scan Mac")
                                }
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.horizontal, 22)
                                .padding(.vertical, 12)
                                .background(
                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                colors: [Color.cyan, Color(red: 0.0, green: 0.45, blue: 1.0)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .shadow(color: Color.cyan.opacity(0.45), radius: 10, x: 0, y: 3)
                                )
                            }
                            .buttonStyle(.plain)
                            .disabled(viewModel.isScanning || viewModel.isCleaning)

                            // Clean All Button
                            if viewModel.scanResult.totalBytes > 0 {
                                Button {
                                    viewModel.cleanSelectedItems()
                                } label: {
                                    HStack(spacing: 8) {
                                        Image(systemName: "sparkles")
                                        Text(viewModel.isCleaning ? "Cleaning..." : "Smart Clean (\(viewModel.scanResult.formattedSelectedSize))")
                                    }
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 22)
                                    .padding(.vertical, 12)
                                    .background(
                                        Capsule()
                                            .fill(
                                                LinearGradient(
                                                    colors: [Color(red: 1.0, green: 0.65, blue: 0.1), Color(red: 1.0, green: 0.25, blue: 0.55)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .shadow(color: Color.pink.opacity(0.45), radius: 12, x: 0, y: 3)
                                    )
                                }
                                .buttonStyle(.plain)
                                .disabled(viewModel.isCleaning || viewModel.isScanning)
                            }
                        }

                        // Scanning or Cleaning Live Indicator
                        if viewModel.isScanning || viewModel.isCleaning {
                            VStack(alignment: .leading, spacing: 6) {
                                ProgressView(value: viewModel.isScanning ? viewModel.scanProgressValue : viewModel.cleanProgressValue, total: 1.0)
                                    .progressViewStyle(.linear)
                                    .tint(viewModel.isScanning ? .cyan : .pink)

                                Text(viewModel.isScanning ? viewModel.scanProgressText : viewModel.cleanProgressText)
                                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            .frame(maxWidth: 420)
                        }
                    }

                    Spacer()
                }
                .padding(28)
                .glassCard(cornerRadius: 24)

                // MODULES SECTION
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("CLEANING MODULES")
                            .font(.system(size: 12, weight: .black, design: .rounded))
                            .tracking(1.4)
                            .foregroundColor(.white.opacity(0.5))

                        Spacer()

                        Text("Select a module to inspect individual files")
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.4))
                    }

                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 18), GridItem(.flexible(), spacing: 18)], spacing: 18) {
                        CategoryCard(
                            category: .quickCache,
                            size: viewModel.scanResult.size(for: .quickCache),
                            itemCount: viewModel.scanResult.itemCount(for: .quickCache),
                            isScanning: viewModel.isScanning,
                            onSelect: { viewModel.selectedSection = .quickCache },
                            onClean: { viewModel.cleanSelectedItems(for: .quickCache) }
                        )

                        CategoryCard(
                            category: .deepClean,
                            size: viewModel.scanResult.size(for: .deepClean),
                            itemCount: viewModel.scanResult.itemCount(for: .deepClean),
                            isScanning: viewModel.isScanning,
                            onSelect: { viewModel.selectedSection = .deepClean },
                            onClean: { viewModel.cleanSelectedItems(for: .deepClean) }
                        )

                        CategoryCard(
                            category: .appLeftovers,
                            size: viewModel.scanResult.size(for: .appLeftovers),
                            itemCount: viewModel.scanResult.itemCount(for: .appLeftovers),
                            isScanning: viewModel.isScanning,
                            onSelect: { viewModel.selectedSection = .appLeftovers },
                            onClean: { viewModel.cleanSelectedItems(for: .appLeftovers) }
                        )

                        CategoryCard(
                            category: .largeFiles,
                            size: viewModel.scanResult.size(for: .largeFiles),
                            itemCount: viewModel.scanResult.itemCount(for: .largeFiles),
                            isScanning: viewModel.isScanning,
                            onSelect: { viewModel.selectedSection = .largeFiles },
                            onClean: { viewModel.cleanSelectedItems(for: .largeFiles) }
                        )
                    }
                }
            }
            .padding(28)
        }
    }
}

private struct MetricPill: View {
    let title: String
    let value: String
    let dotColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack(spacing: 5) {
                Circle().fill(dotColor).frame(width: 5, height: 5)
                Text(title)
                    .font(.system(size: 9, weight: .bold, design: .rounded))
                    .tracking(0.8)
                    .foregroundColor(.white.opacity(0.45))
            }
            Text(value)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
    }
}
