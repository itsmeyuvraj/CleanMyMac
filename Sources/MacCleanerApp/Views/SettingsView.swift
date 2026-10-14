import SwiftUI
import MacCleanerEngine

public struct SettingsView: View {
    @ObservedObject public var viewModel: CleanerViewModel

    public init(viewModel: CleanerViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                // Title
                VStack(alignment: .leading, spacing: 4) {
                    Text("Safety & Clean Settings")
                        .font(.system(size: 26, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                    Text("Configure how MacCleaner handles file deletion and safeguards your system.")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.6))
                }

                // Deletion Method Card
                VStack(alignment: .leading, spacing: 18) {
                    HStack {
                        Image(systemName: "shield.lefthalf.filled")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.cyan)

                        Text("DELETION SAFEGUARDS")
                            .font(.system(size: 11, weight: .black, design: .rounded))
                            .tracking(1.2)
                            .foregroundColor(.white.opacity(0.5))
                    }

                    Toggle(isOn: $viewModel.moveToTrashOnly) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Move to Trash (Recommended & Safe)")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            Text("Moves cleaned items into macOS Trash. Allows you to restore any file anytime with Finder's Put Back.")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                    .toggleStyle(.switch)
                    .tint(.cyan)

                    Divider().background(Color.white.opacity(0.08))

                    Toggle(isOn: $viewModel.dryRunMode) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Dry Run (Simulation Mode)")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            Text("Calculates potential space savings and runs the workflow without touching or modifying any files on disk.")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                    .toggleStyle(.switch)
                    .tint(.orange)
                }
                .padding(24)
                .glassCard(cornerRadius: 20)

                // Safety Guarantee
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.title2)
                            .foregroundColor(Color(red: 0.1, green: 0.95, blue: 0.6))

                        Text("SYSTEM INTEGRITY PROTECTION")
                            .font(.system(size: 11, weight: .black, design: .rounded))
                            .tracking(1.2)
                            .foregroundColor(.white.opacity(0.5))
                    }

                    Text("MacCleaner enforces strict multi-level whitelisting to safeguard your operating system:")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.6))

                    VStack(alignment: .leading, spacing: 12) {
                        SafetyFeatureRow(
                            icon: "folder.badge.person.crop",
                            color: .cyan,
                            title: "Protected User Personal Data",
                            desc: "Documents, Desktop, Pictures, Music, Keychains, and Photos are completely untouched."
                        )

                        SafetyFeatureRow(
                            icon: "apple.logo",
                            color: .purple,
                            title: "Apple System Services Whitelist",
                            desc: "Core services, iCloud Sync, Safari Bookmarks, and System Integrity Protection (SIP) protected directories are never deleted."
                        )

                        SafetyFeatureRow(
                            icon: "clock.arrow.circlepath",
                            color: Color(red: 0.1, green: 0.95, blue: 0.6),
                            title: "Reversible Cleanups",
                            desc: "Items are transferred to your Trash by default, allowing one-click Put Back from Finder."
                        )
                    }
                }
                .padding(24)
                .glassCard(cornerRadius: 20)

                // Architecture
                VStack(alignment: .leading, spacing: 12) {
                    Text("ENGINE ARCHITECTURE")
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .tracking(1.2)
                        .foregroundColor(.white.opacity(0.5))

                    Text("MacCleaner is a 100% native macOS application engineered in Swift 6 & SwiftUI. No electron, no webview, instant execution.")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.6))

                    HStack(spacing: 12) {
                        BadgePill(text: "Apple Silicon Native (ARM64)", color: .cyan)
                        BadgePill(text: "Swift 6 & SwiftUI", color: .purple)
                        BadgePill(text: "macOS Sonoma / Sequoia Ready", color: Color(red: 0.1, green: 0.95, blue: 0.6))
                    }
                }
                .padding(24)
                .glassCard(cornerRadius: 20)
            }
            .padding(28)
        }
    }
}

private struct SafetyFeatureRow: View {
    let icon: String
    let color: Color
    let title: String
    let desc: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle().fill(color.opacity(0.18)).frame(width: 32, height: 32)
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(color)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text(desc)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.55))
            }
        }
    }
}

private struct BadgePill: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .bold, design: .rounded))
            .foregroundColor(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Capsule().fill(color.opacity(0.15)))
            .overlay(Capsule().stroke(color.opacity(0.3), lineWidth: 1))
    }
}
