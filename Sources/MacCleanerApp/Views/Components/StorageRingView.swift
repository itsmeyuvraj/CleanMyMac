import SwiftUI
import MacCleanerEngine

public struct StorageRingView: View {
    public let stats: DiskStats
    public let reclaimableBytes: Int64
    public let isScanning: Bool

    @State private var scanRotation: Double = 0
    @State private var pulseGlow: Bool = false

    public init(stats: DiskStats, reclaimableBytes: Int64, isScanning: Bool = false) {
        self.stats = stats
        self.reclaimableBytes = reclaimableBytes
        self.isScanning = isScanning
    }

    private var reclaimableRatio: Double {
        guard stats.totalBytes > 0 else { return 0 }
        return Double(reclaimableBytes) / Double(stats.totalBytes)
    }

    private var usedExcludingJunkRatio: Double {
        max(0, stats.usedPercentage - reclaimableRatio)
    }

    public var body: some View {
        ZStack {
            // Ambient Outer Glow Aura
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            (isScanning ? Color.cyan.opacity(0.35) : (reclaimableBytes > 0 ? Color.purple.opacity(0.25) : Color.blue.opacity(0.18))),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 80,
                        endRadius: 160
                    )
                )
                .frame(width: 320, height: 320)
                .scaleEffect(pulseGlow ? 1.06 : 0.96)
                .animation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true), value: pulseGlow)

            // Outer decorative tick marks / gauge track
            Circle()
                .stroke(
                    AngularGradient(
                        colors: [
                            Color.white.opacity(0.08),
                            Color.cyan.opacity(0.2),
                            Color.white.opacity(0.08)
                        ],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 2, dash: [4, 8])
                )
                .frame(width: 256, height: 256)
                .rotationEffect(.degrees(isScanning ? scanRotation : 0))

            // Main Background Ring Track (Deep Obsidian Glass)
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.06), Color.white.opacity(0.02)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 22
                )
                .frame(width: 216, height: 216)

            // Used Space Arc (Neon Cyan to Indigo)
            Circle()
                .trim(from: 0, to: CGFloat(usedExcludingJunkRatio))
                .stroke(
                    LinearGradient(
                        colors: [
                            Color(red: 0.0, green: 0.85, blue: 1.0),
                            Color(red: 0.3, green: 0.4, blue: 1.0)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 22, lineCap: .round)
                )
                .frame(width: 216, height: 216)
                .rotationEffect(.degrees(-90))
                .shadow(color: Color.cyan.opacity(0.6), radius: 10, x: 0, y: 0)
                .animation(.spring(response: 0.9, dampingFraction: 0.8), value: usedExcludingJunkRatio)

            // Reclaimable Junk Arc (Hot Amber to Neon Pink)
            if reclaimableBytes > 0 {
                Circle()
                    .trim(from: CGFloat(usedExcludingJunkRatio), to: CGFloat(stats.usedPercentage))
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color(red: 1.0, green: 0.65, blue: 0.1),
                                Color(red: 1.0, green: 0.2, blue: 0.6)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 24, lineCap: .round)
                    )
                    .frame(width: 216, height: 216)
                    .rotationEffect(.degrees(-90))
                    .shadow(color: Color.pink.opacity(0.7), radius: 14, x: 0, y: 0)
                    .animation(.spring(response: 0.9, dampingFraction: 0.8), value: stats.usedPercentage)
            }

            // Radar Scan Sweep Beam (Active when scanning)
            if isScanning {
                Circle()
                    .trim(from: 0.0, to: 0.25)
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [Color.cyan.opacity(0), Color.cyan]),
                            center: .center
                        ),
                        lineWidth: 24
                    )
                    .frame(width: 216, height: 216)
                    .rotationEffect(.degrees(scanRotation))
            }

            // Central Holographic Sphere & Stats
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.white.opacity(0.12),
                                    Color.black.opacity(0.6)
                                ],
                                center: .topLeading,
                                startRadius: 0,
                                endRadius: 60
                            )
                        )
                        .frame(width: 54, height: 54)
                        .overlay(
                            Circle()
                                .stroke(LinearGradient(colors: [Color.white.opacity(0.4), Color.clear], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
                        )

                    Image(systemName: isScanning ? "antenna.radiowaves.left.and.right" : "internaldrive.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: isScanning ? [Color.cyan, Color.white] : [Color.cyan, Color.purple],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }

                Text(stats.formattedFree)
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: Color.black.opacity(0.5), radius: 4, x: 0, y: 2)

                Text("FREE OF \(stats.formattedTotal)")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .tracking(1.5)
                    .foregroundColor(Color.white.opacity(0.5))

                if reclaimableBytes > 0 {
                    HStack(spacing: 5) {
                        Circle()
                            .fill(Color(red: 1.0, green: 0.3, blue: 0.6))
                            .frame(width: 6, height: 6)
                            .shadow(color: .pink, radius: 4)

                        Text("\(ByteCountFormatter.string(fromByteCount: reclaimableBytes, countStyle: .file)) JUNK")
                            .font(.system(size: 10, weight: .black, design: .rounded))
                            .tracking(0.8)
                            .foregroundColor(Color(red: 1.0, green: 0.4, blue: 0.7))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color(red: 1.0, green: 0.2, blue: 0.5).opacity(0.18))
                            .overlay(
                                Capsule().stroke(Color(red: 1.0, green: 0.2, blue: 0.5).opacity(0.4), lineWidth: 1)
                            )
                    )
                }
            }
        }
        .frame(width: 270, height: 270)
        .onAppear {
            pulseGlow = true
            if isScanning {
                withAnimation(.linear(duration: 1.8).repeatForever(autoreverses: false)) {
                    scanRotation = 360
                }
            }
        }
        .onChange(of: isScanning) { newValue in
            if newValue {
                scanRotation = 0
                withAnimation(.linear(duration: 1.8).repeatForever(autoreverses: false)) {
                    scanRotation = 360
                }
            }
        }
    }
}
