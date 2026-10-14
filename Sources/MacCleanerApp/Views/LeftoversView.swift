import SwiftUI
import MacCleanerEngine

public struct LeftoversView: View {
    @ObservedObject public var viewModel: CleanerViewModel

    public init(viewModel: CleanerViewModel) {
        self.viewModel = viewModel
    }

    private var items: [JunkItem] {
        let all = viewModel.scanResult.items(for: .appLeftovers)
        if viewModel.searchQuery.isEmpty {
            return all
        }
        return all.filter {
            $0.name.localizedCaseInsensitiveContains(viewModel.searchQuery) ||
            ($0.associatedApp?.localizedCaseInsensitiveContains(viewModel.searchQuery) ?? false)
        }
    }

    private var totalBytes: Int64 {
        viewModel.scanResult.size(for: .appLeftovers)
    }

    private var selectedBytes: Int64 {
        viewModel.scanResult.selectedSize(for: .appLeftovers)
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Header Action Banner
            HStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(Theme.amberGradient)
                        .blur(radius: 10)
                        .opacity(0.5)
                        .frame(width: 56, height: 56)

                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.18), Color.white.opacity(0.04)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)
                        .overlay(Circle().stroke(Color.orange.opacity(0.5), lineWidth: 1.5))

                    Image(systemName: "trash.slash.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Theme.amberGradient)
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text("Uninstalled App Leftovers")
                            .font(.system(size: 22, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)

                        if selectedBytes > 0 {
                            Text(ByteCountFormatter.string(fromByteCount: selectedBytes, countStyle: .file))
                                .font(.system(size: 13, weight: .black, design: .rounded))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Capsule().fill(Color.orange.opacity(0.25)))
                                .foregroundColor(Color(red: 1.0, green: 0.7, blue: 0.2))
                                .overlay(Capsule().stroke(Color.orange.opacity(0.4), lineWidth: 1))
                        }
                    }

                    Text("When apps are deleted, their Application Support, Caches, and Preferences remain on disk.")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.6))
                }

                Spacer()

                HStack(spacing: 12) {
                    Button {
                        viewModel.scanSingleCategory(.appLeftovers)
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.clockwise")
                            Text("Rescan")
                        }
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 9)
                        .background(Capsule().fill(Color.white.opacity(0.08)))
                        .overlay(Capsule().stroke(Color.white.opacity(0.12), lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                    .disabled(viewModel.isScanning || viewModel.isCleaning)

                    Button {
                        viewModel.cleanSelectedItems(for: .appLeftovers)
                    } label: {
                        HStack(spacing: 7) {
                            Image(systemName: "trash.fill")
                            Text("Purge Leftovers (\(ByteCountFormatter.string(fromByteCount: selectedBytes, countStyle: .file)))")
                        }
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 9)
                        .background(
                            Capsule()
                                .fill(Theme.amberGradient)
                                .shadow(color: Color.orange.opacity(0.5), radius: 10, x: 0, y: 3)
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(selectedBytes == 0 || viewModel.isCleaning || viewModel.isScanning)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
            .background(Color.black.opacity(0.3))

            Divider().background(Color.white.opacity(0.08))

            // Sub-toolbar
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.orange.opacity(0.8))
                        .font(.caption)
                    Text("\(items.count) Uninstalled Apps with Orphaned Traces Found")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                }

                Spacer()

                HStack(spacing: 10) {
                    Button("Select All") {
                        viewModel.setAllSelection(for: .appLeftovers, isSelected: true)
                    }
                    .buttonStyle(.plain)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 1.0, green: 0.7, blue: 0.2))

                    Text("•").foregroundColor(.white.opacity(0.3)).font(.caption2)

                    Button("Deselect All") {
                        viewModel.setAllSelection(for: .appLeftovers, isSelected: false)
                    }
                    .buttonStyle(.plain)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 1.0, green: 0.7, blue: 0.2))
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 10)
            .background(Color.black.opacity(0.15))

            Divider().background(Color.white.opacity(0.08))

            // Content List
            if items.isEmpty {
                VStack(spacing: 18) {
                    Spacer()
                    ZStack {
                        Circle()
                            .fill(Color.orange.opacity(0.1))
                            .frame(width: 90, height: 90)

                        Image(systemName: "app.badge.checkmark")
                            .font(.system(size: 48))
                            .foregroundStyle(Theme.amberGradient)
                    }

                    Text("No App Leftovers Detected")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text("No leftover files from uninstalled applications were detected on your system.")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.5))

                    Button("Scan Leftovers Now") {
                        viewModel.scanSingleCategory(.appLeftovers)
                    }
                    .buttonStyle(.plain)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 9)
                    .background(Capsule().fill(Theme.amberGradient))

                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(items) { item in
                            JunkItemRow(
                                item: item,
                                onToggle: { viewModel.toggleItemSelection(id: item.id) },
                                onReveal: { viewModel.revealInFinder(url: $0) }
                            )
                        }
                    }
                    .padding(24)
                }
            }
        }
    }
}
