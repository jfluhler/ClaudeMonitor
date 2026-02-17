import SwiftUI

struct UsagePanelView: View {
    @ObservedObject var viewModel: UsageViewModel
    @State private var selectedTab = 0
    @State private var showingHelp = false

    var body: some View {
        VStack(spacing: 0) {
            if !viewModel.disclaimerAccepted {
                DisclaimerView {
                    viewModel.acceptDisclaimer()
                }
            } else {
                // Header
                HStack {
                    Image(systemName: "gauge.with.dots.needle.33percent")
                        .foregroundStyle(.secondary)
                    Text("ClaudeMonitor")
                        .font(.headline)
                    Spacer()
                    Button {
                        showingHelp.toggle()
                    } label: {
                        Image(systemName: "questionmark.circle")
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.borderless)
                    .help("How it works")
                }
                .padding(.horizontal)
                .padding(.top, 12)
                .padding(.bottom, 8)

                switch viewModel.connectionState {
                case .loading:
                    VStack(spacing: 8) {
                        ProgressView()
                        Text("Connecting...")
                            .foregroundStyle(.secondary)
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(40)

                case .disconnected(let reason):
                    OnboardingView(reason: reason, viewModel: viewModel)

                case .connected:
                    connectedContent
                }
            }
        }
        .frame(width: 320)
        .popover(isPresented: $showingHelp, arrowEdge: .top) {
            HelpView()
        }
    }

    @ViewBuilder
    private var connectedContent: some View {
        Picker("", selection: $selectedTab) {
            Text("Current").tag(0)
            Text("History").tag(1)
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
        .padding(.bottom, 8)

        if selectedTab == 0 {
            currentUsageView
        } else {
            HistoryView(historyService: viewModel.historyService)
        }

        Divider()
            .padding(.top, 4)

        footerView
    }

    private var currentUsageView: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let fiveHour = viewModel.usageData?.fiveHour {
                SessionUsageView(
                    window: fiveHour,
                    timeRemaining: viewModel.timeRemaining(until: fiveHour.resetDate),
                    color: viewModel.utilizationColor(fiveHour.utilization)
                )
            }

            Divider()

            if let sevenDay = viewModel.usageData?.sevenDay {
                UsageBarView(
                    title: "Weekly Usage (7-day)",
                    window: sevenDay,
                    resetText: viewModel.resetDateText(for: sevenDay.resetDate),
                    color: viewModel.utilizationColor(sevenDay.utilization)
                )
            }

            if let opus = viewModel.usageData?.sevenDayOpus {
                UsageBarView(
                    title: "Opus Weekly (7-day)",
                    window: opus,
                    resetText: viewModel.resetDateText(for: opus.resetDate),
                    color: viewModel.utilizationColor(opus.utilization)
                )
            }

            Divider()

            longTermSummary
        }
        .padding(.horizontal)
    }

    private var longTermSummary: some View {
        let avg30 = viewModel.historyService.averageUtilization(forLastDays: 30)
        let limitDays30 = viewModel.historyService.daysLimitHit(forLastDays: 30)
        let avg365 = viewModel.historyService.averageUtilization(forLastDays: 365)

        return VStack(alignment: .leading, spacing: 4) {
            Text("Long-term")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack {
                Label {
                    Text(String(format: "30d avg: %.0f%%", avg30.fiveHour))
                } icon: {
                    Image(systemName: "calendar")
                }
                .font(.caption)

                Spacer()

                Label {
                    Text(String(format: "Year avg: %.0f%%", avg365.fiveHour))
                } icon: {
                    Image(systemName: "calendar.badge.clock")
                }
                .font(.caption)
            }

            Text("Limit hit \(limitDays30) of last 30 days")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var footerView: some View {
        HStack {
            if let lastRefreshed = viewModel.lastRefreshed {
                Text("Updated \(lastRefreshed, style: .time)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                Task { await viewModel.refresh() }
            } label: {
                Image(systemName: "arrow.clockwise")
                    .font(.caption)
            }
            .buttonStyle(.borderless)
            .help("Refresh now")

            SettingsLink {
                Image(systemName: "gear")
                    .font(.caption)
            }
            .buttonStyle(.borderless)
            .help("Settings")

            Button {
                NSApplication.shared.terminate(nil)
            } label: {
                Image(systemName: "power")
                    .font(.caption)
            }
            .buttonStyle(.borderless)
            .help("Quit")
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}
