import ServiceManagement
import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: UsageViewModel

    var body: some View {
        Form {
            Section("Polling") {
                HStack {
                    Text("Refresh every \(Int(viewModel.pollInterval))s")
                    Spacer()
                    Slider(value: $viewModel.pollInterval, in: 30...300, step: 10) {
                        Text("Poll Interval")
                    }
                    .frame(width: 200)
                    .onChange(of: viewModel.pollInterval) { _, _ in
                        viewModel.startPolling()
                    }
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
