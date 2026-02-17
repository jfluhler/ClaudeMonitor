import SwiftUI

struct SessionUsageView: View {
    let window: UsageWindow
    let timeRemaining: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Text("Session Usage (5-hour)")
                .font(.subheadline)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 16) {
                // Circular progress ring
                ZStack {
                    Circle()
                        .stroke(.quaternary, lineWidth: 8)

                    Circle()
                        .trim(from: 0, to: min(window.utilization / 100.0, 1.0))
                        .stroke(
                            color,
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.5), value: window.utilization)

                    Text(String(format: "%.0f%%", window.utilization))
                        .font(.system(.title2, design: .rounded, weight: .bold))
                }
                .frame(width: 80, height: 80)

                VStack(alignment: .leading, spacing: 4) {
                    Text(String(format: "%.1f%% used", window.utilization))
                        .font(.title3)
                        .fontWeight(.semibold)

                    Label {
                        Text("Resets in \(timeRemaining)")
                    } icon: {
                        Image(systemName: "clock")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)

                    if window.utilization >= 100 {
                        Label("Limit reached", systemImage: "exclamationmark.triangle.fill")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }

                Spacer()
            }
        }
    }
}
