import ServiceManagement
import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: UsageViewModel

    var body: some View {
        Form {
            Section("Polling") {
                Picker("Refresh every", selection: $viewModel.pollInterval) {
                    Text("5 minutes").tag(300.0)
                    Text("15 minutes").tag(900.0)
                    Text("30 minutes").tag(1800.0)
                    Text("60 minutes").tag(3600.0)
                }
                .onChange(of: viewModel.pollInterval) { _, _ in
                    viewModel.startPolling()
                }
            }

            Section("Menu Bar") {
                Toggle("Show percentage next to icon", isOn: $viewModel.showPercentageInMenuBar)
            }

            Section("Notifications") {
                Toggle(
                    "Notify when session usage exceeds 80%",
                    isOn: $viewModel.notifyAt80Percent
                )
            }

            Section("System") {
                Toggle("Launch at login", isOn: $viewModel.launchAtLogin)
                    .onChange(of: viewModel.launchAtLogin) { _, newValue in
                        do {
                            if newValue {
                                try SMAppService.mainApp.register()
                            } else {
                                try SMAppService.mainApp.unregister()
                            }
                        } catch {
                            // Revert on failure
                            viewModel.launchAtLogin = !newValue
                        }
                    }
            }
        }
        .formStyle(.grouped)
        .frame(width: 420, height: 320)
    }
}
