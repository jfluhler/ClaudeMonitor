import SwiftUI
import UserNotifications

enum ConnectionState: Equatable {
    case connected
    case disconnected(String)
    case loading
}

@MainActor
final class UsageViewModel: ObservableObject {
    // MARK: - Published State

    @Published var usageData: UsageResponse?
    @Published var connectionState: ConnectionState = .loading
    @Published var lastRefreshed: Date?
    @Published var now = Date()

    // MARK: - Settings

    @AppStorage("pollInterval") var pollInterval: Double = 60
    @AppStorage("showPercentageInMenuBar") var showPercentageInMenuBar: Bool = false
    @AppStorage("launchAtLogin") var launchAtLogin: Bool = false
    @AppStorage("notifyAt80Percent") var notifyAt80Percent: Bool = true
    @AppStorage("disclaimerAccepted") var disclaimerAccepted: Bool = false

    // MARK: - Services

    let historyService = UsageHistoryService.shared

    // MARK: - Timers

    private var pollTimer: Timer?
    private var countdownTimer: Timer?

    // MARK: - Init

    init() {
        startCountdownTimer()
        if disclaimerAccepted {
            beginConnecting()
        }
    }

    func acceptDisclaimer() {
        disclaimerAccepted = true
        beginConnecting()
    }

    private func beginConnecting() {
        Task {
            try? await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound])
            await refresh()
            startPolling()
        }
    }

    // MARK: - Data Fetching

    func refresh() async {
        do {
            let token = try KeychainService.shared.getOAuthToken()
            let data = try await APIService.shared.fetchUsage(token: token)
            usageData = data
            connectionState = .connected
            lastRefreshed = Date()

            historyService.record(usage: data)

            if let fiveHour = data.fiveHour {
                if fiveHour.utilization < 80 {
                    NotificationService.shared.resetNotificationFlag()
                }
                if notifyAt80Percent {
                    NotificationService.shared.checkAndNotify(
                        utilization: fiveHour.utilization,
                        resetDate: fiveHour.resetDate
                    )
                }
            }
        } catch {
            connectionState = .disconnected(
                (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            )
        }
    }

    // MARK: - Polling

    func startPolling() {
        pollTimer?.invalidate()
        pollTimer = Timer.scheduledTimer(
            withTimeInterval: pollInterval, repeats: true
        ) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in await self.refresh() }
        }
    }

    private func startCountdownTimer() {
        countdownTimer = Timer.scheduledTimer(
            withTimeInterval: 1, repeats: true
        ) { [weak self] _ in
            Task { @MainActor in self?.now = Date() }
        }
    }

    // MARK: - Computed Helpers

    var fiveHourUtilization: Double {
        usageData?.fiveHour?.utilization ?? 0
    }

    var isLimitHit: Bool {
        fiveHourUtilization >= 100
    }

    func timeRemaining(until date: Date?) -> String {
        guard let date else { return "—" }
        let interval = date.timeIntervalSince(now)
        guard interval > 0 else { return "Any moment now" }

        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        let seconds = Int(interval) % 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m \(seconds)s"
    }

    func resetDateText(for date: Date?) -> String {
        guard let date else { return "—" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        return formatter.string(from: date)
    }

    func utilizationColor(_ value: Double) -> Color {
        switch value {
        case ..<50: return .green
        case ..<80: return .yellow
        default: return .red
        }
    }
}
