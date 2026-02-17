import SwiftUI

struct OnboardingView: View {
    let reason: String
    @ObservedObject var viewModel: UsageViewModel

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 36))
                .foregroundStyle(.yellow)

            Text("Not Connected")
                .font(.headline)

            Text(reason)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Text("To use ClaudeMonitor:")
                    .font(.caption)
                    .fontWeight(.medium)

                Label("Install Claude Code (claude.ai/code)", systemImage: "1.circle")
                    .font(.caption)
                Label("Log in by running: claude login", systemImage: "2.circle")
                    .font(.caption)
                Label("Click Retry below", systemImage: "3.circle")
                    .font(.caption)
            }

            Button("Retry Connection") {
                Task { await viewModel.refresh() }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity)
    }
}
