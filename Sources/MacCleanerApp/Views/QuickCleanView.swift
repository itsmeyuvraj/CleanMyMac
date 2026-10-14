import SwiftUI
import MacCleanerEngine

public struct QuickCleanView: View {
    @ObservedObject public var viewModel: CleanerViewModel
    @State private var selectedFilter: String = "All"

    public init(viewModel: CleanerViewModel) {
        self.viewModel = viewModel
    }

    private var filterOptions: [String] {
        ["All", "Web Browsers", "Developer Tools", "Messaging & Communication", "Application Caches"]
    }

    private var items: [JunkItem] {
        let all = viewModel.scanResult.items(for: .quickCache)
        let filteredByTab: [JunkItem]
        if selectedFilter == "All" {
            filteredByTab = all
        } else {
            filteredByTab = all.filter { $0.subCategory == selectedFilter }
        }

        if viewModel.searchQuery.isEmpty {
            return filteredByTab
        }
        return filteredByTab.filter {
            $0.name.localizedCaseInsensitiveContains(viewModel.searchQuery) ||
            $0.subCategory.localizedCaseInsensitiveContains(viewModel.searchQuery)
        }
    }

    private var totalBytes: Int64 {
        viewModel.scanResult.size(for: .quickCache)
    }

    private var selectedBytes: Int64 {
        viewModel.scanResult.selectedSize(for: .quickCache)
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Top Glowing Header
            HStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(Theme.cyanGradient)
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
                        .overlay(Circle().stroke(Color.cyan.opacity(0.5), lineWidth: 1.5))

                    Image(systemName: "bolt.fill")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(Theme.cyanGradient)
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text("1-Click Quick Cache Clean")
                            .font(.system(size: 22, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)

                        if selectedBytes > 0 {
                            Text(ByteCountFormatter.string(fromByteCount: selectedBytes, countStyle: .file))
                                .font(.system(size: 13, weight: .black, design: .rounded))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Capsule().fill(Color.cyan.opacity(0.2)))
                                .foregroundColor(.cyan)
                                .overlay(Capsule().stroke(Color.cyan.opacity(0.4), lineWidth: 1))
                        }
                    }

                    Text("Purge browser history cache, app downloads, and temporary caches in a single click.")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.6))
                }

                Spacer()

                HStack(spacing: 12) {
                    Button {
                        viewModel.scanSingleCategory(.quickCache)
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
                        viewModel.cleanSelectedItems(for: .quickCache)
                    } label: {
                        HStack(spacing: 7) {
                            Image(systemName: "sparkles")
                            Text("Clean Cache (\(ByteCountFormatter.string(fromByteCount: selectedBytes, countStyle: .file)))")
                        }
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 9)
                        .background(
                            Capsule()
                                .fill(Theme.cyanGradient)
                                .shadow(color: Color.cyan.opacity(0.5), radius: 10, x: 0, y: 3)
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

            // Filter Tabs & Select All Bar
            HStack(spacing: 12) {
                // Filter Tabs
                HStack(spacing: 8) {
                    ForEach(filterOptions, id: \.self) { tab in
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedFilter = tab
                            }
                        } label: {
                            Text(tab)
                                .font(.system(size: 11, weight: selectedFilter == tab ? .bold : .medium, design: .rounded))
                                .foregroundColor(selectedFilter == tab ? .white : .white.opacity(0.5))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 5)
                                .background(
                                    Capsule()
                                        .fill(selectedFilter == tab ? Color.cyan.opacity(0.25) : Color.white.opacity(0.04))
                                )
                                .overlay(
                                    Capsule()
                                        .stroke(selectedFilter == tab ? Color.cyan.opacity(0.5) : Color.clear, lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }

                Spacer()

                HStack(spacing: 10) {
                    Button("Select All") {
                        viewModel.setAllSelection(for: .quickCache, isSelected: true)
                    }
                    .buttonStyle(.plain)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(.cyan)

                    Text("•").foregroundColor(.white.opacity(0.3)).font(.caption2)

                    Button("Deselect All") {
                        viewModel.setAllSelection(for: .quickCache, isSelected: false)
                    }
                    .buttonStyle(.plain)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(.cyan)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 10)
            .background(Color.black.opacity(0.15))

            Divider().background(Color.white.opacity(0.08))

            // List of Cache Findings
            if items.isEmpty {
                VStack(spacing: 18) {
                    Spacer()
                    ZStack {
                        Circle()
                            .fill(Color.cyan.opacity(0.1))
                            .frame(width: 90, height: 90)

                        Image(systemName: "checkmark.shield.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(Theme.cyanGradient)
                    }

                    Text("No Cache Files Found")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text("Your application and browser caches are completely optimized.")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.5))

                    Button("Scan Again") {
                        viewModel.scanSingleCategory(.quickCache)
                    }
                    .buttonStyle(.plain)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 9)
                    .background(Capsule().fill(Theme.cyanGradient))

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
