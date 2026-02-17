import SwiftUI

@main
struct ClaudeMonApp: App {
    @StateObject private var viewModel = UsageViewModel()

    var body: some Scene {
        MenuBarExtra {
            UsagePanelView(viewModel: viewModel)
        } label: {
            MenuBarIconView(viewModel: viewModel)
        }
        .menuBarExtraStyle(.window)

        Settings {
            SettingsView(viewModel: viewModel)
        }
    }
}
