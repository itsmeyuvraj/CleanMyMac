import SwiftUI
import MacCleanerEngine

public struct LargeFilesView: View {
    @ObservedObject public var viewModel: CleanerViewModel

    public init(viewModel: CleanerViewModel) {
        self.viewModel = viewModel
    }

    private var items: [JunkItem] {
        let all = viewModel.scanResult.items(for: .largeFiles)
        if viewModel.searchQuery.isEmpty {
            return all
        }
        return all.filter {
            $0.name.localizedCaseInsensitiveContains(viewModel.searchQuery) ||
            $0.subCategory.localizedCaseInsensitiveContains(viewModel.searchQuery)
        }
    }

    private var totalBytes: Int64 {
        viewModel.scanResult.size(for: .largeFiles)
    }

    private var selectedBytes: Int64 {
        viewModel.scanResult.selectedSize(for: .largeFiles)
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Header Action Banner
            HStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(Theme.emeraldGradient)
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
                        .overlay(Circle().stroke(Color.green.opacity(0.5), lineWidth: 1.5))

                    Image(systemName: "shippingbox.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Theme.emeraldGradient)
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text("Large Files & Old Installers")
                            .font(.system(size: 22, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)

                        if selectedBytes > 0 {
                            Text(ByteCountFormatter.string(fromByteCount: selectedBytes, countStyle: .file))
                                .font(.system(size: 13, weight: .black, design: .rounded))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Capsule().fill(Color.green.opacity(0.25)))
                                .foregroundColor(Color(red: 0.1, green: 0.95, blue: 0.6))
                                .overlay(Capsule().stroke(Color.green.opacity(0.4), lineWidth: 1))
                        }
                    }

                    Text("Detect forgotten .dmg disk image installers, old .pkg files, and archives in Downloads & Desktop.")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.6))
                }

                Spacer()

                HStack(spacing: 12) {
                    Button {
                        viewModel.scanSingleCategory(.largeFiles)
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
                        viewModel.cleanSelectedItems(for: .largeFiles)
                    } label: {
                        HStack(spacing: 7) {
                            Image(systemName: "trash.fill")
                            Text("Remove Selected (\(ByteCountFormatter.string(fromByteCount: selectedBytes, countStyle: .file)))")
                        }
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 9)
                        .background(
                            Capsule()
                                .fill(Theme.emeraldGradient)
                                .shadow(color: Color.green.opacity(0.5), radius: 10, x: 0, y: 3)
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
                Text("\(items.count) Heavy Files Detected • Total: \(ByteCountFormatter.string(fromByteCount: totalBytes, countStyle: .file))")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))

                Spacer()

                HStack(spacing: 10) {
                    Button("Select All") {
                        viewModel.setAllSelection(for: .largeFiles, isSelected: true)
                    }
                    .buttonStyle(.plain)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.1, green: 0.95, blue: 0.6))

                    Text("•").foregroundColor(.white.opacity(0.3)).font(.caption2)

                    Button("Deselect All") {
                        viewModel.setAllSelection(for: .largeFiles, isSelected: false)
                    }
                    .buttonStyle(.plain)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.1, green: 0.95, blue: 0.6))
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
                            .fill(Color.green.opacity(0.1))
                            .frame(width: 90, height: 90)

                        Image(systemName: "shippingbox")
                            .font(.system(size: 48))
                            .foregroundStyle(Theme.emeraldGradient)
                    }

                    Text("No Large Files Found")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text("No unused DMG installers or hefty archives detected in Downloads or Desktop.")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.5))

                    Button("Scan Large Files") {
                        viewModel.scanSingleCategory(.largeFiles)
                    }
                    .buttonStyle(.plain)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 9)
                    .background(Capsule().fill(Theme.emeraldGradient))

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
