//
//  LearningSwiftApp.swift
//  LearningSwift
//
//  Created by Maciej Sitkowski on 30/05/2025.
//
import Sparkle
import SwiftUI

@main
struct LearningSwiftApp: App {
    private let updaterController = SPUStandardUpdaterController(
        startingUpdater: true, updaterDelegate: nil, userDriverDelegate: nil)

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .commands {
            CommandGroup(after: .appInfo) {
                CheckForUpdatesButton(updater: updaterController.updater)
            }
        }
    }
}

struct CheckForUpdatesButton: View {
    let updater: SPUUpdater
    @State private var canCheckForUpdates = false

    var body: some View {
        Button("Check for Updates...") {
            updater.checkForUpdates()
        }
        .disabled(!canCheckForUpdates)
        .onReceive(updater.publisher(for: \.canCheckForUpdates)) { value in
            canCheckForUpdates = value
        }
    }
}
