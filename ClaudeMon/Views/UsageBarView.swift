import SwiftUI

struct UsageBarView: View {
    let title: String
    let window: UsageWindow
    let resetText: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Text(String(format: "%.0f%%", window.utilization))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(color)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.quaternary)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geo.size.width * min(window.utilization / 100.0, 1.0))
                        .animation(.easeInOut(duration: 0.5), value: window.utilization)
                }
            }
            .frame(height: 8)

            Text("Resets \(resetText)")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}
