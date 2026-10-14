import SwiftUI
import AppKit

public enum Theme {
    // Background Colors
    public static let bgDeep = Color(red: 0.04, green: 0.05, blue: 0.08)
    public static let bgSurface = Color(red: 0.07, green: 0.09, blue: 0.14)
    public static let bgCard = Color(red: 0.10, green: 0.12, blue: 0.18).opacity(0.7)
    public static let bgCardHover = Color(red: 0.13, green: 0.16, blue: 0.24).opacity(0.85)

    // Vibrant Accent Gradients
    public static let cyanGradient = LinearGradient(
        colors: [Color(red: 0.0, green: 0.85, blue: 1.0), Color(red: 0.0, green: 0.5, blue: 1.0)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    public static let purpleGradient = LinearGradient(
        colors: [Color(red: 0.75, green: 0.35, blue: 1.0), Color(red: 0.45, green: 0.15, blue: 0.9)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    public static let amberGradient = LinearGradient(
        colors: [Color(red: 1.0, green: 0.65, blue: 0.1), Color(red: 1.0, green: 0.35, blue: 0.1)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    public static let emeraldGradient = LinearGradient(
        colors: [Color(red: 0.1, green: 0.95, blue: 0.6), Color(red: 0.0, green: 0.7, blue: 0.4)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    public static let heroGradient = LinearGradient(
        colors: [
            Color(red: 0.0, green: 0.85, blue: 1.0),
            Color(red: 0.6, green: 0.3, blue: 1.0),
            Color(red: 1.0, green: 0.25, blue: 0.55)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // Border highlights
    public static let glassBorder = LinearGradient(
        colors: [Color.white.opacity(0.22), Color.white.opacity(0.04), Color.white.opacity(0.12)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    public static let activeBorder = LinearGradient(
        colors: [Color.cyan.opacity(0.8), Color.purple.opacity(0.6), Color.cyan.opacity(0.3)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    public static func playSound(_ name: String = "Glass") {
        NSSound(named: name)?.play()
    }
}

// Glassmorphism Card Modifier
public struct GlassCard: ViewModifier {
    var cornerRadius: CGFloat = 18
    var borderColor: LinearGradient = Theme.glassBorder
    var isHovered: Bool = false

    public func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(isHovered ? Theme.bgCardHover : Theme.bgCard)
                    .background(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(.ultraThinMaterial)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(isHovered ? Theme.activeBorder : borderColor, lineWidth: isHovered ? 1.5 : 1)
            )
            .shadow(color: isHovered ? Color.cyan.opacity(0.18) : Color.black.opacity(0.35), radius: isHovered ? 16 : 10, x: 0, y: isHovered ? 6 : 4)
    }
}

public extension View {
    func glassCard(cornerRadius: CGFloat = 18, isHovered: Bool = false) -> some View {
        self.modifier(GlassCard(cornerRadius: cornerRadius, isHovered: isHovered))
    }
}
