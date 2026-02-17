# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

ClaudeMonitor is a macOS menu bar app (SwiftUI, macOS 14+) that displays Claude AI subscription usage limits. It polls an undocumented Anthropic OAuth usage endpoint and shows session/weekly/opus utilization in the menu bar with a dropdown panel.

## Build & Run

```bash
# Generate Xcode project (after modifying project.yml)
xcodegen generate

# Build from command line
xcodebuild -project ClaudeMon.xcodeproj -scheme ClaudeMon -configuration Debug build

# Release build for notarization
./scripts/build-and-notarize.sh

# Open in Xcode
open ClaudeMon.xcodeproj
```

The app requires macOS 14.0+ and uses "Sign to Run Locally" for development builds. No sandbox — the app needs direct Keychain access to read Claude Code's OAuth token.

## Notarization

Requires a Developer ID Application certificate and stored notarytool credentials. See `scripts/build-and-notarize.sh` header for one-time setup steps. Team ID: `J5RUB49AW6`. Bundle ID: `com.jfluhler.claudemonitor`.

## Architecture

### Data Flow
`Keychain → APIService → UsageViewModel → SwiftUI Views`

The app reads Claude Code's OAuth token from the macOS Keychain (service: `"Claude Code-credentials"`, field: `claudeAiOauth.accessToken`), polls `GET https://api.anthropic.com/api/oauth/usage` on a configurable interval, and drives all UI through a single `@MainActor UsageViewModel`.

### Key Components

- **Models/** — `UsageResponse`/`UsageWindow` (API response), `DailyUsageRecord`/`UsageHistoryData` (local history persistence)
- **Services/** — `KeychainService` (Security framework, no CLI shelling), `APIService` (async/await URLSession), `UsageHistoryService` (JSON file in ~/Library/Application Support/ClaudeMon/), `NotificationService` (UNUserNotificationCenter)
- **ViewModels/** — `UsageViewModel` owns all state, two timers (poll timer + 1-second countdown timer for live reset countdowns), `@AppStorage` for settings
- **Views/** — `MenuBarIconView` (custom NSImage circle gauge), `UsagePanelView` (main popover with Current/History tabs), `SessionUsageView` (circular progress ring), `UsageBarView` (horizontal bar), `HistoryView` (Swift Charts), `SettingsView`, `OnboardingView`

### App Entry Point
`ClaudeMonApp.swift` uses `MenuBarExtra` with `.menuBarExtraStyle(.window)` for the popover panel and a `Settings` scene for the preferences window. `LSUIElement=true` hides the dock icon.

### Long-term Tracking
`UsageHistoryService` records daily peak utilization snapshots (up to 400 days) to `~/Library/Application Support/ClaudeMon/usage_history.json`. The History tab shows 30-day and yearly charts with Swift Charts.

## Key Design Decisions

- **No sandbox**: Required to read another app's Keychain item. First launch may prompt user to allow Keychain access.
- **Two timers**: Poll timer (configurable 30-300s) fetches fresh data; countdown timer (1s) keeps "resets in X" live without extra API calls.
- **NSImage for menu bar icon**: Drawn programmatically with NSBezierPath for the colored circular gauge — SF Symbols don't support partial fills.
- **xcodegen**: Project file generated from `project.yml`. Re-run `xcodegen generate` after adding/removing source files.
- **Hardened runtime**: Enabled for notarization compatibility. Non-sandboxed for Keychain cross-app access.
