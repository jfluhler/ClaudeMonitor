import Foundation

struct DailyUsageRecord: Codable, Identifiable {
    var id: String { dateString }
    let dateString: String
    var peakFiveHour: Double
    var peakSevenDay: Double
    var peakOpus: Double?
    var limitHitCount: Int
    var sampleCount: Int

    var date: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: dateString)
    }
}

struct UsageHistoryData: Codable {
    var dailyRecords: [DailyUsageRecord]

    static let empty = UsageHistoryData(dailyRecords: [])
}
