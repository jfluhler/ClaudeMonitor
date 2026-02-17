import SwiftUI

struct MenuBarIconView: View {
    @ObservedObject var viewModel: UsageViewModel
    @State private var isPulsing = false

    var body: some View {
        HStack(spacing: 2) {
            Image(nsImage: makeIcon())
                .opacity(isPulsing ? 0.3 : 1.0)

            if viewModel.showPercentageInMenuBar {
                Text("\(Int(viewModel.fiveHourUtilization))%")
                    .monospacedDigit()
            }
        }
        .onChange(of: viewModel.isLimitHit) { _, isHit in
            if isHit {
                withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                    isPulsing = true
                }
            } else {
                withAnimation(.default) {
                    isPulsing = false
                }
            }
        }
    }

    private func makeIcon() -> NSImage {
        let size = NSSize(width: 18, height: 18)
        let image = NSImage(size: size, flipped: false) { rect in
            let lineWidth: CGFloat = 2.0
            let inset: CGFloat = 2.0
            let circleRect = rect.insetBy(dx: inset, dy: inset)
            let center = NSPoint(x: rect.midX, y: rect.midY)
            let radius = circleRect.width / 2

            // Background track
            let bgPath = NSBezierPath(ovalIn: circleRect)
            NSColor.tertiaryLabelColor.setStroke()
            bgPath.lineWidth = lineWidth
            bgPath.stroke()

            // Usage arc
            let utilization = self.viewModel.fiveHourUtilization
            guard utilization > 0 else { return true }

            let color: NSColor = {
                switch utilization {
                case ..<50: return .systemGreen
                case ..<80: return .systemYellow
                default: return .systemRed
                }
            }()

            let startAngle: CGFloat = 90
            let endAngle = startAngle - (360.0 * min(utilization, 100) / 100.0)

            let arcPath = NSBezierPath()
            arcPath.appendArc(
                withCenter: center, radius: radius,
                startAngle: startAngle, endAngle: endAngle,
                clockwise: true
            )
            color.setStroke()
            arcPath.lineWidth = lineWidth
            arcPath.lineCapStyle = .round
            arcPath.stroke()

            return true
        }
        image.isTemplate = false
        return image
    }
}
