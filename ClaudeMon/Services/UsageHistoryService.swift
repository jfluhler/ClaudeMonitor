import Foundation

final class UsageHistoryService {
    static let shared = UsageHistoryService()

    private var historyData: UsageHistoryData
    private let fileURL: URL

    private init() {
        let appSupport = FileManager.default.urls(
            for: .applicationSupportDirectory, in: .userDomainMask
        ).first!
        let appDir = appSupport.appendingPathComponent("ClaudeMonitor", isDirectory: true)
        try? FileManager.default.createDirectory(at: appDir, withIntermediateDirectories: true)

        fileURL = appDir.appendingPathComponent("usage_history.json")

        if let data = try? Data(contentsOf: fileURL),
           let history = try? JSONDecoder().decode(UsageHistoryData.self, from: data)
        {
            historyData = history
        } else {
            historyData = .empty
        }
    }

    func record(usage: UsageResponse) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let today = formatter.string(from: Date())

        let fiveHour = usage.fiveHour?.utilization ?? 0
        let sevenDay = usage.sevenDay?.utilization ?? 0
        let opus = usage.sevenDayOpus?.utilization
        let hitLimit = fiveHour >= 100.0

        if let index = historyData.dailyRecords.firstIndex(where: { $0.dateString == today }) {
            var record = historyData.dailyRecords[index]
            record.peakFiveHour = max(record.peakFiveHour, fiveHour)
            record.peakSevenDay = max(record.peakSevenDay, sevenDay)
            if let o = opus {
                record.peakOpus = max(record.peakOpus ?? 0, o)
            }
            if hitLimit { record.limitHitCount += 1 }
            record.sampleCount += 1
            historyData.dailyRecords[index] = record
        } else {
            let record = DailyUsageRecord(
                dateString: today,
                peakFiveHour: fiveHour,
                peakSevenDay: sevenDay,
                peakOpus: opus,
                limitHitCount: hitLimit ? 1 : 0,
                sampleCount: 1
            )
            historyData.dailyRecords.append(record)
        }

        // Keep last 400 days
        if historyData.dailyRecords.count > 400 {
            historyData.dailyRecords = Array(historyData.dailyRecords.suffix(400))
        }

        save()
    }

    func records(forLastDays days: Int) -> [DailyUsageRecord] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let cutoff = Calendar.current.date(byAdding: .day, value: -days, to: Date()) else {
            return []
        }
        let cutoffString = formatter.string(from: cutoff)
        return historyData.dailyRecords
            .filter { $0.dateString >= cutoffString }
            .sorted { $0.dateString < $1.dateString }
    }

    func averageUtilization(forLastDays days: Int) -> (fiveHour: Double, sevenDay: Double, opus: Double?) {
        let records = records(forLastDays: days)
        guard !records.isEmpty else { return (0, 0, nil) }

        let avgFive = records.map(\.peakFiveHour).reduce(0, +) / Double(records.count)
        let avgSeven = records.map(\.peakSevenDay).reduce(0, +) / Double(records.count)

        let opusRecords = records.compactMap(\.peakOpus)
        let avgOpus: Double? = opusRecords.isEmpty
            ? nil
            : opusRecords.reduce(0, +) / Double(opusRecords.count)

        return (avgFive, avgSeven, avgOpus)
    }

    func daysLimitHit(forLastDays days: Int) -> Int {
        records(forLastDays: days).filter { $0.limitHitCount > 0 }.count
    }

    private func save() {
        if let data = try? JSONEncoder().encode(historyData) {
            try? data.write(to: fileURL, options: .atomic)
        }
    }
}
