import ServiceManagement
import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: UsageViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Polling")
                .font(.headline)
            Picker("Refresh every", selection: $viewModel.pollInterval) {
                Text("5 minutes").tag(300.0)
                Text("15 minutes").tag(900.0)
                Text("30 minutes").tag(1800.0)
                Text("60 minutes").tag(3600.0)
            }
            .onChange(of: viewModel.pollInterval) { _, _ in
                viewModel.startPolling()
            }

            Divider()

            Text("Menu Bar")
                .font(.headline)
            Toggle("Show percentage next to icon", isOn: $viewModel.showPercentageInMenuBar)

            Divider()

            Text("Notifications")
                .font(.headline)
            Toggle("Notify when session usage exceeds 80%", isOn: $viewModel.notifyAt80Percent)

            Divider()

            Text("System")
                .font(.headline)
            Toggle("Launch at login", isOn: $viewModel.launchAtLogin)
                .onChange(of: viewModel.launchAtLogin) { _, newValue in
                    do {
                        if newValue {
                            try SMAppService.mainApp.register()
                        } else {
                            try SMAppService.mainApp.unregister()
                        }
                    } catch {
                        viewModel.launchAtLogin = !newValue
                    }
                }

            Spacer()

            HStack {
                Text("ClaudeMonitor")
                    .foregroundStyle(.secondary)
                Spacer()
                Text(appVersion)
                    .foregroundStyle(.secondary)
            }
            .font(.caption)
        }
        .padding(20)
        .frame(width: 360, height: 320)
    }

    private var appVersion: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "?"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "?"
        return "v\(version) (\(build))"
    }
}
