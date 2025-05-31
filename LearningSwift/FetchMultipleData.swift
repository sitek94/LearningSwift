//
//  FetchMultipleData.swift
//  LearningSwift
//
//  Created by Maciej Sitkowski on 31/05/2025.
//

import SwiftUI

private struct UserProfile {
    let name: String
    let age: Int
}

private struct AppSettings {
    let theme: String
    let language: String
}

struct FetchMultipleData: View {
    @State private var isLoading = true
    @State private var userProfile: UserProfile?
    @State private var appSettings: AppSettings?

    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
            }

            if let userProfile = userProfile {
                Text("User Profile: \(userProfile.name), \(userProfile.age)")
                Divider()
            }
            
            if let appSettings = appSettings {
                Text("App Settings: \(appSettings.theme), \(appSettings.language)")
            }
        }
        .padding()
        .task {
            let (profile, settings) = await fetchData()

            isLoading = false

            userProfile = profile
            appSettings = settings
        }
    }
}

private func fetchData() async -> (UserProfile, AppSettings) {
    async let userProfile = fetchUserProfile()
    async let appSettings = fetchAppSettings()

    let profile = await userProfile
    let settings = await appSettings

    return (profile, settings)
}

private func fetchUserProfile() async -> UserProfile {
    try? await Task.sleep(nanoseconds: 2_000_000_000)

    return UserProfile(name: "John Doe", age: 30)
}

private func fetchAppSettings() async -> AppSettings {
    try? await Task.sleep(nanoseconds: 2_000_000_000)

    return AppSettings(theme: "Light", language: "English")
}

#Preview {
    FetchMultipleData()
        .frame(width: 200, height: 100)
}
