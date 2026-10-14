import SwiftUI
import MacCleanerEngine

public struct MainView: View {
    @StateObject private var viewModel = CleanerViewModel()

    public init() {}

    public var body: some View {
        ZStack {
            // Cosmic Deep Aurora Ambient Background
            Theme.bgDeep
                .ignoresSafeArea()

            // Subtle Glowing Ambient Auroras
            GeometryReader { proxy in
                ZStack {
                    Circle()
                        .fill(Color.cyan.opacity(0.12))
                        .blur(radius: 120)
                        .frame(width: 450, height: 450)
                        .offset(x: -80, y: -120)

                    Circle()
                        .fill(Color.purple.opacity(0.12))
                        .blur(radius: 140)
                        .frame(width: 500, height: 500)
                        .offset(x: proxy.size.width - 250, y: proxy.size.height - 250)
                }
            }
            .ignoresSafeArea()

            NavigationSplitView {
                // LUXURY SIDEBAR
                VStack(spacing: 0) {
                    // App Brand Header
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Theme.heroGradient)
                                .frame(width: 36, height: 36)
                                .shadow(color: Color.cyan.opacity(0.5), radius: 8)

                            Image(systemName: "sparkles")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                        }

                        VStack(alignment: .leading, spacing: 1) {
                            HStack(spacing: 6) {
                                Text("MacCleaner")
                                    .font(.system(size: 16, weight: .heavy, design: .rounded))
                                    .foregroundColor(.white)

                                Text("PRO")
                                    .font(.system(size: 9, weight: .black, design: .rounded))
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 2)
                                    .background(Capsule().fill(Theme.cyanGradient))
                                    .foregroundColor(.black)
                            }

                            Text("macOS System Optimizer")
                                .font(.system(size: 10))
                                .foregroundColor(.white.opacity(0.45))
                        }

                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .padding(.bottom, 20)

                    // Navigation Items
                    ScrollView {
                        VStack(spacing: 6) {
                            ForEach(NavigationSection.allCases) { section in
                                SidebarItemRow(
                                    section: section,
                                    isSelected: viewModel.selectedSection == section,
                                    badgeSize: badgeSize(for: section),
                                    onSelect: { viewModel.selectedSection = section }
                                )
                            }
                        }
                        .padding(.horizontal, 14)
                    }

                    Spacer()

                    // Bottom Disk Capacity Bar
                    VStack(spacing: 10) {
                        Divider().background(Color.white.opacity(0.08))

                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                HStack(spacing: 5) {
                                    Image(systemName: "internaldrive.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(.cyan)

                                    Text("Macintosh HD")
                                        .font(.system(size: 11, weight: .bold, design: .rounded))
                                        .foregroundColor(.white.opacity(0.8))
                                }

                                Spacer()

                                Button {
                                    viewModel.refreshDiskStats()
                                } label: {
                                    Image(systemName: "arrow.clockwise")
                                        .font(.system(size: 11))
                                        .foregroundColor(.white.opacity(0.4))
                                }
                                .buttonStyle(.plain)
                            }

                            // Storage Mini Progress Bar
                            GeometryReader { g in
                                ZStack(alignment: .leading) {
                                    Capsule()
                                        .fill(Color.white.opacity(0.1))
                                        .frame(height: 6)

                                    Capsule()
                                        .fill(Theme.cyanGradient)
                                        .frame(width: max(8, g.size.width * CGFloat(viewModel.diskStats.usedPercentage)), height: 6)
                                        .shadow(color: Color.cyan.opacity(0.6), radius: 4)
                                }
                            }
                            .frame(height: 6)

                            HStack {
                                Text("\(viewModel.diskStats.formattedFree) Free")
                                    .font(.system(size: 10, weight: .bold, design: .rounded))
                                    .foregroundColor(.cyan)

                                Spacer()

                                Text(viewModel.diskStats.formattedTotal)
                                    .font(.system(size: 10, weight: .medium, design: .rounded))
                                    .foregroundColor(.white.opacity(0.4))
                            }
                        }
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.white.opacity(0.04))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                                )
                        )
                        .padding(.horizontal, 14)
                        .padding(.bottom, 16)
                    }
                }
                .frame(minWidth: 230, idealWidth: 250, maxWidth: 280)
                .background(Color.black.opacity(0.25))
            } detail: {
                // DETAIL MAIN CANVAS
                ZStack {
                    Group {
                        switch viewModel.selectedSection {
                        case .dashboard:
                            DashboardView(viewModel: viewModel)
                        case .quickCache:
                            QuickCleanView(viewModel: viewModel)
                        case .deepClean:
                            DeepCleanView(viewModel: viewModel)
                        case .appLeftovers:
                            LeftoversView(viewModel: viewModel)
                        case .largeFiles:
                            LargeFilesView(viewModel: viewModel)
                        case .settings:
                            SettingsView(viewModel: viewModel)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                    // Celebration Overlay
                    if viewModel.showSuccessCelebration, let result = viewModel.lastCleanResult {
                        ConfettiView(
                            isPresented: $viewModel.showSuccessCelebration,
                            reclaimedText: result.formattedReclaimed
                        )
                    }
                }
                .toolbar {
                    ToolbarItemGroup(placement: .automatic) {
                        if viewModel.selectedSection != .dashboard && viewModel.selectedSection != .settings {
                            HStack(spacing: 8) {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.white.opacity(0.4))
                                    .font(.system(size: 12))

                                TextField("Search items...", text: $viewModel.searchQuery)
                                    .textFieldStyle(.plain)
                                    .font(.system(size: 12))
                                    .frame(width: 150)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(
                                Capsule()
                                    .fill(Color.white.opacity(0.07))
                                    .overlay(Capsule().stroke(Color.white.opacity(0.12), lineWidth: 1))
                            )
                        }

                        Button {
                            viewModel.startFullScan()
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                    .font(.system(size: 11, weight: .bold))
                                    .rotationEffect(.degrees(viewModel.isScanning ? 360 : 0))
                                    .animation(viewModel.isScanning ? .linear(duration: 1).repeatForever(autoreverses: false) : .default, value: viewModel.isScanning)

                                Text(viewModel.isScanning ? "Scanning..." : "Full Scan")
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(Theme.cyanGradient)
                                    .shadow(color: Color.cyan.opacity(0.4), radius: 6, x: 0, y: 2)
                            )
                        }
                        .buttonStyle(.plain)
                        .disabled(viewModel.isScanning || viewModel.isCleaning)
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
        .frame(minWidth: 960, minHeight: 650)
        .onAppear {
            viewModel.startFullScan()
        }
    }

    private func badgeSize(for section: NavigationSection) -> Int64? {
        switch section {
        case .dashboard: return viewModel.scanResult.totalBytes
        case .quickCache: return viewModel.scanResult.size(for: .quickCache)
        case .deepClean: return viewModel.scanResult.size(for: .deepClean)
        case .appLeftovers: return viewModel.scanResult.size(for: .appLeftovers)
        case .largeFiles: return viewModel.scanResult.size(for: .largeFiles)
        case .settings: return nil
        }
    }
}

private struct SidebarItemRow: View {
    let section: NavigationSection
    let isSelected: Bool
    let badgeSize: Int64?
    let onSelect: () -> Void

    @State private var isHovered: Bool = false

    private var sectionColor: Color {
        switch section {
        case .dashboard: return Color.cyan
        case .quickCache: return Color.cyan
        case .deepClean: return Color(red: 0.75, green: 0.35, blue: 1.0)
        case .appLeftovers: return Color(red: 1.0, green: 0.65, blue: 0.1)
        case .largeFiles: return Color(red: 0.1, green: 0.95, blue: 0.6)
        case .settings: return Color.white.opacity(0.6)
        }
    }

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                ZStack {
                    if isSelected {
                        Circle()
                            .fill(sectionColor.opacity(0.3))
                            .frame(width: 28, height: 28)
                    }

                    Image(systemName: section.iconName)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(isSelected ? sectionColor : .white.opacity(0.6))
                }
                .frame(width: 28, height: 28)

                Text(section.title)
                    .font(.system(size: 13, weight: isSelected ? .bold : .medium, design: .rounded))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.75))

                Spacer()

                if let size = badgeSize, size > 0 {
                    Text(ByteCountFormatter.string(fromByteCount: size, countStyle: .file))
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(isSelected ? .white : sectionColor)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(
                            Capsule()
                                .fill(isSelected ? sectionColor : sectionColor.opacity(0.2))
                        )
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.white.opacity(0.12) : (isHovered ? Color.white.opacity(0.04) : Color.clear))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? sectionColor.opacity(0.4) : Color.clear, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
        .onHover { h in isHovered = h }
    }
}
