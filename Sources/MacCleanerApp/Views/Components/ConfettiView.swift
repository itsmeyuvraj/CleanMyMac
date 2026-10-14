import SwiftUI

public struct ConfettiView: View {
    @Binding public var isPresented: Bool
    public let reclaimedText: String

    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0.0

    public init(isPresented: Binding<Bool>, reclaimedText: String) {
        self._isPresented = isPresented
        self.reclaimedText = reclaimedText
    }

    public var body: some View {
        ZStack {
            // Dark Frosted Backdrop
            Color.black.opacity(0.65)
                .background(.ultraThinMaterial)
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }

            // Celebration Modal Card
            VStack(spacing: 24) {
                // Glowing Animated Checkmark Badge
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(red: 0.1, green: 0.95, blue: 0.6).opacity(0.4),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 20,
                                endRadius: 70
                            )
                        )
                        .frame(width: 140, height: 140)

                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.1, green: 0.95, blue: 0.6),
                                    Color(red: 0.0, green: 0.8, blue: 1.0)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 76, height: 76)
                        .shadow(color: Color(red: 0.1, green: 0.95, blue: 0.6).opacity(0.6), radius: 16)

                    Image(systemName: "checkmark")
                        .font(.system(size: 36, weight: .black))
                        .foregroundColor(.black)
                }

                VStack(spacing: 8) {
                    Text("Mac Clean Complete!")
                        .font(.system(size: 26, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)

                    Text("You safely liberated")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.6))

                    Text(reclaimedText)
                        .font(.system(size: 38, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.1, green: 0.95, blue: 0.6),
                                    Color(red: 0.0, green: 0.85, blue: 1.0)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: Color.cyan.opacity(0.5), radius: 10, x: 0, y: 0)

                    Text("of disk space from clutter, caches & leftovers.")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.6))
                }

                Button {
                    dismiss()
                } label: {
                    Text("Done")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(width: 160, height: 42)
                        .background(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.cyan, Color.blue],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .shadow(color: Color.cyan.opacity(0.5), radius: 12, x: 0, y: 4)
                        )
                }
                .buttonStyle(.plain)
                .keyboardShortcut(.defaultAction)
            }
            .padding(36)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color(red: 0.08, green: 0.10, blue: 0.16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .stroke(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.3), Color.cyan.opacity(0.4), Color.clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .shadow(color: Color.black.opacity(0.6), radius: 30, x: 0, y: 15)
            )
            .frame(maxWidth: 420)
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            Theme.playSound("Glass")
            withAnimation(.spring(response: 0.45, dampingFraction: 0.7)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }

    private func dismiss() {
        withAnimation(.easeOut(duration: 0.2)) {
            scale = 0.85
            opacity = 0.0
            isPresented = false
        }
    }
}
