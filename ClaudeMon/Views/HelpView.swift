import SwiftUI

struct HelpView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "questionmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.blue)
                Text("How ClaudeMonitor Works")
                    .font(.headline)
                Spacer()
            }

            Divider()

            VStack(alignment: .leading, spacing: 12) {
                helpSection(
                    icon: "key.fill",
                    title: "Authentication",
                    body: "ClaudeMonitor reads the OAuth token that Claude Code stores in your macOS Keychain. It does not have its own login — it piggybacks on Claude Code's session."
                )

                helpSection(
                    icon: "terminal.fill",
                    title: "Requirement: Claude Code",
                    body: "You must have Claude Code (the CLI tool) installed and logged in. Run \"claude login\" in your terminal if you haven't already. Claude Desktop alone is not sufficient."
                )

                helpSection(
                    icon: "network",
                    title: "Undocumented API",
                    body: "Usage data comes from an internal Anthropic endpoint used by Claude Code itself. This is not an official public API — it may change without notice."
                )

                helpSection(
                    icon: "clock.arrow.circlepath",
                    title: "Token Refresh",
                    body: "If the token expires, ClaudeMonitor will show a disconnected state. Re-run \"claude login\" or start any Claude Code session to refresh the token, then click Retry."
                )

                helpSection(
                    icon: "lock.shield",
                    title: "Keychain Access",
                    body: "On first launch, macOS may ask you to allow ClaudeMonitor to access a Keychain item. Click \"Always Allow\" to prevent repeated prompts."
                )

                helpSection(
                    icon: "chart.bar.fill",
                    title: "Usage Limits",
                    body: "Session (5-hour) and weekly (7-day) utilization are percentages of your plan's rate limits. When session usage hits 100%, Claude Code requests will be throttled until the window resets."
                )
            }

            Divider()

            Text("Quick Start")
                .font(.subheadline)
                .fontWeight(.semibold)

            VStack(alignment: .leading, spacing: 4) {
                stepRow(num: 1, text: "Install Claude Code: npm install -g @anthropic-ai/claude-code")
                stepRow(num: 2, text: "Log in: claude login")
                stepRow(num: 3, text: "Launch ClaudeMonitor — it will find the token automatically")
            }
        }
        .padding()
        .frame(width: 400)
    }

    private func helpSection(icon: String, title: String, body: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(.secondary)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(body)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func stepRow(num: Int, text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text("\(num).")
                .font(.caption)
                .fontWeight(.bold)
                .frame(width: 16, alignment: .trailing)
            Text(text)
                .font(.caption)
                .textSelection(.enabled)
        }
    }
}
