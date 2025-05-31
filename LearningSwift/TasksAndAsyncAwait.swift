//
//  TasksAndAsyncAwait.swift
//  LearningSwift
//
//  Created by Maciej Sitkowski on 31/05/2025.
//

import SwiftUI

struct TasksAndAsyncAwait: View {
    @State private var isLoading = true
    @State private var message = "💤 Idle"

    var body: some View {
        VStack {
            Text("Fetching simulator")

            Text(message)
                .frame(width: 200)
                .padding()
                .border(.gray)

            Button("Fetch") {
                guard !isLoading else { return }

                isLoading = true
                message = "⏳ Fetching..."

                Task {
                    message = await fetchTranscriptFromServerSafely()
                    isLoading = false
                }
            }
            .disabled(isLoading)
        }
        .padding()
        .task {
            message = "⏳ Fetching..."
            message = await fetchTranscriptFromServerSafely()
            isLoading = false
        }
    }
}

private func fetchTranscriptFromServer() async throws -> String {
    print("Starting to fetch transcript...")

    // Simulate network delay - Task.sleep can only be called from an async context
    // or within a Task.
    try await Task.sleep(nanoseconds: 1_000_000_000)  // Pauses for 2 seconds

    // Simulate error
    if Bool.random() {
        throw NSError(domain: "com.example.error", code: 100, userInfo: nil)
    }

    print("Finished fetching transcript.")
    return "✅ This is a fetched transcript from the server."
}

private func fetchTranscriptFromServerSafely() async -> String {
    do {
        return try await fetchTranscriptFromServer()
    } catch {
        print("Error fetching transcript: \(error)")
        return "❌ Error fetching transcript"
    }
}

#Preview {
    TasksAndAsyncAwait()
}
