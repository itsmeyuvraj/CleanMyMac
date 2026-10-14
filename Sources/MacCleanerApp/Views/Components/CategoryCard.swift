import SwiftUI
import MacCleanerEngine

public struct CategoryCard: View {
    public let category: CleanCategory
    public let size: Int64
    public let itemCount: Int
    public let isScanning: Bool
    public let onSelect: () -> Void
    public let onClean: () -> Void

    @State private var isHovered: Bool = false

    public init(
        category: CleanCategory,
        size: Int64,
        itemCount: Int,
        isScanning: Bool = false,
        onSelect: @escaping () -> Void,
        onClean: @escaping () -> Void
    ) {
        self.category = category
        self.size = size
        self.itemCount = itemCount
        self.isScanning = isScanning
        self.onSelect = onSelect
        self.onClean = onClean
    }

    private var gradient: LinearGradient {
        switch category {
        case .quickCache: return Theme.cyanGradient
        case .deepClean: return Theme.purpleGradient
        case .appLeftovers: return Theme.amberGradient
        case .largeFiles: return Theme.emeraldGradient
        }
    }

    private var accentColor: Color {
        switch category {
        case .quickCache: return Color(red: 0.0, green: 0.85, blue: 1.0)
        case .deepClean: return Color(red: 0.75, green: 0.35, blue: 1.0)
        case .appLeftovers: return Color(red: 1.0, green: 0.65, blue: 0.1)
        case .largeFiles: return Color(red: 0.1, green: 0.95, blue: 0.6)
        }
    }

    public var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 14) {
                // Top Row: 3D Glowing Icon + Size Badge
                HStack(alignment: .top) {
                    ZStack {
                        // Ambient icon glow
                        RoundedRectangle(cornerRadius: 14)
                            .fill(gradient)
                            .blur(radius: 8)
                            .opacity(isHovered ? 0.6 : 0.3)
                            .frame(width: 48, height: 48)

                        // Icon Base Plate
                        RoundedRectangle(cornerRadius: 14)
                            .fill(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.18), Color.white.opacity(0.04)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 48, height: 48)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(
                                        LinearGradient(
                                            colors: [Color.white.opacity(0.4), accentColor.opacity(0.3)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                            )

                        Image(systemName: category.iconName)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(gradient)
                    }

                    Spacer()

                    if size > 0 {
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(ByteCountFormatter.string(fromByteCount: size, countStyle: .file))
                                .font(.system(size: 18, weight: .heavy, design: .rounded))
                                .foregroundStyle(gradient)
                                .shadow(color: accentColor.opacity(0.4), radius: 6, x: 0, y: 0)

                            Text("\(itemCount) items")
                                .font(.system(size: 11, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.5))
                        }
                    } else if isScanning {
                        ProgressView()
                            .scaleEffect(0.7)
                            .tint(accentColor)
                    } else {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption2)
                            Text("Clean")
                                .font(.caption.bold())
                        }
                        .foregroundColor(Color.white.opacity(0.4))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Color.white.opacity(0.05)))
                    }
                }

                // Title & Subtitle
                VStack(alignment: .leading, spacing: 4) {
                    Text(category.title)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text(category.subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.6))
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 4)

                // Bottom Action Bar
                HStack {
                    if size > 0 {
                        Button {
                            onClean()
                        } label: {
                            HStack(spacing: 5) {
                                Image(systemName: "sparkles")
                                Text("Clean Now")
                            }
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(
                                Capsule()
                                    .fill(gradient)
                                    .shadow(color: accentColor.opacity(0.4), radius: 6, x: 0, y: 2)
                            )
                        }
                        .buttonStyle(.plain)
                    } else {
                        Text("Optimized")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(.white.opacity(0.35))
                    }

                    Spacer()

                    HStack(spacing: 4) {
                        Text("Inspect")
                        Image(systemName: "arrow.right")
                    }
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(isHovered ? accentColor : .white.opacity(0.5))
                }
            }
            .padding(18)
            .frame(height: 172)
            .glassCard(cornerRadius: 20, isHovered: isHovered)
            .scaleEffect(isHovered ? 1.015 : 1.0)
            .animation(.spring(response: 0.35, dampingFraction: 0.75), value: isHovered)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}
