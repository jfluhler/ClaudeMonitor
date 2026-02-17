import UserNotifications

@MainActor
final class NotificationService {
    static let shared = NotificationService()
    private var hasNotifiedThisWindow = false

    private init() {}

    func checkAndNotify(utilization: Double, resetDate: Date?) {
        guard utilization >= 80, !hasNotifiedThisWindow else { return }

        hasNotifiedThisWindow = true

        let content = UNMutableNotificationContent()
        content.title = "ClaudeMonitor"
        content.body = String(format: "Session usage at %.0f%%. Consider pacing your usage.", utilization)
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "usage-warning-\(UUID().uuidString)",
            content: content,
            trigger: nil
        )
        UNUserNotificationCenter.current().add(request)
    }

    func resetNotificationFlag() {
        hasNotifiedThisWindow = false
    }
}
