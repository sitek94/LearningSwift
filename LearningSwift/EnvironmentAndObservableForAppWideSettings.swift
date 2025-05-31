//
//  EnvironmentAndObservableForAppWideSettings.swift
//  LearningSwift
//
//  Created by Maciej Sitkowski on 30/05/2025.
//
import Observation
import SwiftUI

// Shared settings object
@Observable
private class AppSettings {
    var appName: String = "EchoNote"
    var useDarkMode: Bool = false
}

// Injecting into the environment at view level for the sake of example
// but normally it'd most likely be at the app level
struct EnvironmentAndObservableForAppWideSettings: View {
    @State private var appSettings = AppSettings()

    var body: some View {
        VStack {
            Text("[Root] (fake app level)")
            Divider()
            Some()
        }
        .padding()
        .environment(appSettings)
    }
}

// Intermediate view that uses the settings
private struct Some: View {
    @Environment(AppSettings.self) var settings

    var body: some View {
        Text("[Some] App name: \(settings.appName)")
        Divider()
        SomeDeepChild()
    }
}

// Accessing in a descendant view
private struct SomeDeepChild: View {
    @Environment(AppSettings.self) var settings  // Accessing AppSettings

    var body: some View {
        VStack {
            Text("[SomeDeepChild] Dark mode: \(settings.useDarkMode ? "On" : "Off")")

            SettingsPanel(settings: settings)
        }
    }
}

private struct SettingsPanel: View {
    @Bindable var settings: AppSettings

    var body: some View {
        Toggle("Dark mode", isOn: $settings.useDarkMode)
    }
}

#Preview {
    EnvironmentAndObservableForAppWideSettings()
}
