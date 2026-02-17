import Charts
import SwiftUI

struct HistoryView: View {
    let historyService: UsageHistoryService
    @State private var selectedPeriod: HistoryPeriod = .month

    enum HistoryPeriod: String, CaseIterable {
        case month = "30 Days"
        case year = "Year"
    }

    var body: some View {
        let days = selectedPeriod == .month ? 30 : 365
        let records = historyService.records(forLastDays: days)
        let averages = historyService.averageUtilization(forLastDays: days)
        let limitDays = historyService.daysLimitHit(forLastDays: days)

        VStack(alignment: .leading, spacing: 12) {
            Picker("Period", selection: $selectedPeriod) {
                ForEach(HistoryPeriod.allCases, id: \.self) {
                    Text($0.rawValue).tag($0)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()

            // Summary cards
            HStack(spacing: 8) {
                StatCard(
                    title: "Avg Session",
                    value: String(format: "%.0f%%", averages.fiveHour),
                    color: colorFor(averages.fiveHour)
                )
                StatCard(
                    title: "Avg Weekly",
                    value: String(format: "%.0f%%", averages.sevenDay),
                    color: colorFor(averages.sevenDay)
                )
                StatCard(
                    title: "At Limit",
                    value: "\(limitDays)d",
                    color: limitDays > 5 ? .red : .green
                )
            }

            // Chart
            if records.isEmpty {
                Text("No history data yet.\nUsage is recorded over time.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            } else {
                Text("Peak Session Usage")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Chart(records) { record in
                    if let date = record.date {
                        BarMark(
                            x: .value("Date", date, unit: .day),
                            y: .value("Peak %", record.peakFiveHour)
                        )
                        .foregroundStyle(colorFor(record.peakFiveHour).gradient)
                    }
                }
                .chartYScale(domain: 0...100)
                .chartYAxis {
                    AxisMarks(values: [0, 50, 100]) { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if let v = value.as(Int.self) {
                                Text("\(v)%").font(.system(size: 9))
                            }
                        }
                    }
                }
                .frame(height: 140)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
    }

    private func colorFor(_ value: Double) -> Color {
        switch value {
        case ..<50: return .green
        case ..<80: return .yellow
        default: return .red
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(.title3, design: .rounded, weight: .bold))
                .foregroundStyle(color)
            Text(title)
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 6))
    }
}
