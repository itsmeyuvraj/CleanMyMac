import SwiftUI
import MacCleanerEngine

public struct JunkItemRow: View {
    public let item: JunkItem
    public let onToggle: () -> Void
    public let onReveal: (URL) -> Void

    @State private var isExpanded: Bool = false
    @State private var isHovered: Bool = false

    public init(
        item: JunkItem,
        onToggle: @escaping () -> Void,
        onReveal: @escaping (URL) -> Void
    ) {
        self.item = item
        self.onToggle = onToggle
        self.onReveal = onReveal
    }

    private var categoryColor: Color {
        switch item.category {
        case .quickCache: return Color(red: 0.0, green: 0.85, blue: 1.0)
        case .deepClean: return Color(red: 0.75, green: 0.35, blue: 1.0)
        case .appLeftovers: return Color(red: 1.0, green: 0.65, blue: 0.1)
        case .largeFiles: return Color(red: 0.1, green: 0.95, blue: 0.6)
        }
    }

    public var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 14) {
                // Custom Neon Checkbox
                Button(action: onToggle) {
                    ZStack {
                        Circle()
                            .fill(item.isSelected ? categoryColor : Color.white.opacity(0.08))
                            .frame(width: 20, height: 20)
                            .shadow(color: item.isSelected ? categoryColor.opacity(0.6) : .clear, radius: 6)

                        if item.isSelected {
                            Image(systemName: "checkmark")
                                .font(.system(size: 10, weight: .black))
                                .foregroundColor(.black)
                        } else {
                            Circle()
                                .stroke(Color.white.opacity(0.2), lineWidth: 1.5)
                                .frame(width: 20, height: 20)
                        }
                    }
                }
                .buttonStyle(.plain)

                // Item Information
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 8) {
                        Text(item.name)
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.white)

                        if let app = item.associatedApp {
                            HStack(spacing: 4) {
                                Image(systemName: "trash.slash.fill")
                                    .font(.system(size: 8))
                                Text("Uninstalled: \(app)")
                                    .font(.system(size: 10, weight: .bold, design: .rounded))
                            }
                            .padding(.horizontal, 7)
                            .padding(.vertical, 2)
                            .background(Color.orange.opacity(0.18))
                            .foregroundColor(Color(red: 1.0, green: 0.7, blue: 0.2))
                            .overlay(Capsule().stroke(Color.orange.opacity(0.4), lineWidth: 0.8))
                            .clipShape(Capsule())
                        }
                    }

                    HStack(spacing: 6) {
                        Text(item.subCategory)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(categoryColor.opacity(0.9))

                        Text("•")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.3))

                        Text(item.path.path)
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(.white.opacity(0.4))
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }
                }

                Spacer()

                // Size Badge
                Text(item.formattedSize)
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.08))
                            .overlay(Capsule().stroke(Color.white.opacity(0.12), lineWidth: 1))
                    )

                // Reveal in Finder Button
                Button {
                    onReveal(item.path)
                } label: {
                    Image(systemName: "folder.badge.gearshape")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(isHovered ? categoryColor : .white.opacity(0.5))
                        .frame(width: 28, height: 28)
                        .background(Circle().fill(Color.white.opacity(0.06)))
                }
                .buttonStyle(.plain)
                .help("Reveal file in Finder")

                // Sub-items toggle
                if !item.subItems.isEmpty {
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                            isExpanded.toggle()
                        }
                    } label: {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white.opacity(0.6))
                            .rotationEffect(.degrees(isExpanded ? 180 : 0))
                            .frame(width: 24, height: 24)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            // Expanded Sub-Files Tree
            if isExpanded && !item.subItems.isEmpty {
                VStack(spacing: 4) {
                    Divider()
                        .background(Color.white.opacity(0.08))
                        .padding(.horizontal, 16)

                    ForEach(item.subItems.prefix(15)) { sub in
                        HStack {
                            Image(systemName: "doc.text.fill")
                                .font(.system(size: 10))
                                .foregroundColor(categoryColor.opacity(0.8))

                            Text(sub.name)
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(.white.opacity(0.85))
                                .lineLimit(1)
                                .truncationMode(.middle)

                            Spacer()

                            Text(sub.formattedSize)
                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                                .foregroundColor(.white.opacity(0.45))

                            Button {
                                onReveal(sub.path)
                            } label: {
                                Image(systemName: "arrow.up.right.square")
                                    .font(.system(size: 11))
                                    .foregroundColor(.white.opacity(0.4))
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 28)
                        .padding(.vertical, 3)
                    }

                    if item.subItems.count > 15 {
                        Text("+ \(item.subItems.count - 15) more files...")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white.opacity(0.4))
                            .padding(.top, 2)
                    }
                }
                .padding(.bottom, 10)
                .background(Color.black.opacity(0.25))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(isHovered ? Theme.bgCardHover : Theme.bgCard)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(isHovered ? categoryColor.opacity(0.5) : Color.white.opacity(0.06), lineWidth: 1)
        )
        .shadow(color: isHovered ? categoryColor.opacity(0.12) : Color.black.opacity(0.2), radius: 8, x: 0, y: 2)
        .onHover { h in
            isHovered = h
        }
    }
}
