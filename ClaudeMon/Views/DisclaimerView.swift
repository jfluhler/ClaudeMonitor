import SwiftUI

struct DisclaimerView: View {
    let onAccept: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.shield")
                .font(.system(size: 36))
                .foregroundStyle(.orange)

            Text("Before You Continue")
                .font(.headline)

            ScrollView {
                Text(disclaimerText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxHeight: 200)

            Divider()

            Button("I Understand and Accept") {
                onAccept()
            }
            .buttonStyle(.borderedProminent)

            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .buttonStyle(.borderless)
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
    }

    private var disclaimerText: String {
        """
        ClaudeMonitor uses an undocumented, internal Anthropic API endpoint \
        that is not part of any official public API. This endpoint is used \
        internally by Claude Code and was discovered through observation \
        of its network behavior.

        This endpoint may change, break, or be removed at any time without \
        notice. The use of this endpoint may currently or in the future \
        violate Anthropic's Terms of Service, Acceptable Use Policy, or \
        other agreements governing your use of Claude products.

        This project is not affiliated with, endorsed by, or sponsored by \
        Anthropic. The developers make no representations about the legality \
        or permissibility of accessing this endpoint.

        By clicking "I Understand and Accept", you acknowledge these risks \
        and accept sole responsibility for your use of this software.
        """
    }
}
