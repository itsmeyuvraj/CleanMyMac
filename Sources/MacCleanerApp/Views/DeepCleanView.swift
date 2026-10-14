import SwiftUI
import MacCleanerEngine

public struct DeepCleanView: View {
    @ObservedObject public var viewModel: CleanerViewModel
    @State private var selectedFilter: String = "All"

    public init(viewModel: CleanerViewModel) {
        self.viewModel = viewModel
    }

    private var filterOptions: [String] {
        ["All", "Developer Junk", "System Logs & Reports", "Residual App State", "Trash", "Downloads Junk"]
    }

    private var items: [JunkItem] {
        let all = viewModel.scanResult.items(for: .deepClean)
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
        viewModel.scanResult.size(for: .deepClean)
    }

    private var selectedBytes: Int64 {
        viewModel.scanResult.selectedSize(for: .deepClean)
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Header Action Banner
            HStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(Theme.purpleGradient)
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
                        .overlay(Circle().stroke(Color.purple.opacity(0.5), lineWidth: 1.5))

                    Image(systemName: "sparkles.rectangle.stack.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Theme.purpleGradient)
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text("Deep System Clean")
                            .font(.system(size: 22, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)

                        if selectedBytes > 0 {
                            Text(ByteCountFormatter.string(fromByteCount: selectedBytes, countStyle: .file))
                                .font(.system(size: 13, weight: .black, design: .rounded))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Capsule().fill(Color.purple.opacity(0.25)))
                                .foregroundColor(Color(red: 0.8, green: 0.45, blue: 1.0))
                                .overlay(Capsule().stroke(Color.purple.opacity(0.4), lineWidth: 1))
                        }
                    }

                    Text("Purge deep developer build artifacts (Xcode DerivedData), crash dumps, simulator caches, and Trash.")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.6))
                }

                Spacer()

                HStack(spacing: 12) {
                    Button {
                        viewModel.scanSingleCategory(.deepClean)
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
                        viewModel.cleanSelectedItems(for: .deepClean)
                    } label: {
                        HStack(spacing: 7) {
                            Image(systemName: "trash.fill")
                            Text("Deep Clean (\(ByteCountFormatter.string(fromByteCount: selectedBytes, countStyle: .file)))")
                        }
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 9)
                        .background(
                            Capsule()
                                .fill(Theme.purpleGradient)
                                .shadow(color: Color.purple.opacity(0.5), radius: 10, x: 0, y: 3)
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

            // Sub-toolbar with Filter Chips
            HStack(spacing: 12) {
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
                                        .fill(selectedFilter == tab ? Color.purple.opacity(0.3) : Color.white.opacity(0.04))
                                )
                                .overlay(
                                    Capsule()
                                        .stroke(selectedFilter == tab ? Color.purple.opacity(0.6) : Color.clear, lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }

                Spacer()

                HStack(spacing: 10) {
                    Button("Select All") {
                        viewModel.setAllSelection(for: .deepClean, isSelected: true)
                    }
                    .buttonStyle(.plain)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.8, green: 0.45, blue: 1.0))

                    Text("•").foregroundColor(.white.opacity(0.3)).font(.caption2)

                    Button("Deselect All") {
                        viewModel.setAllSelection(for: .deepClean, isSelected: false)
                    }
                    .buttonStyle(.plain)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.8, green: 0.45, blue: 1.0))
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 10)
            .background(Color.black.opacity(0.15))

            Divider().background(Color.white.opacity(0.08))

            // List of Deep Findings
            if items.isEmpty {
                VStack(spacing: 18) {
                    Spacer()
                    ZStack {
                        Circle()
                            .fill(Color.purple.opacity(0.1))
                            .frame(width: 90, height: 90)

                        Image(systemName: "sparkles")
                            .font(.system(size: 48))
                            .foregroundStyle(Theme.purpleGradient)
                    }

                    Text("Deep System Clean")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text("No developer junk, crash logs, or residual simulator files found.")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.5))

                    Button("Deep Scan Now") {
                        viewModel.scanSingleCategory(.deepClean)
                    }
                    .buttonStyle(.plain)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 9)
                    .background(Capsule().fill(Theme.purpleGradient))

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
