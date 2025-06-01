import Foundation
import Observation

enum SpeechError: Error, LocalizedError {
    case recognizerUnavailable
    case recognitionFailed(reason: String)
    case audioInputError

    var errorDescription: String? {
        switch self {
        case .recognizerUnavailable:
            return "Speech recognizer is not available on this device."
        case .recognitionFailed(let reason):
            return "Recognition failed: \(reason)"
        case .audioInputError:
            return "There was an issue with the audio input."
        }
    }
}

// Business logic - no UI concerns
actor SpeechEngine {
    private var isActive = false
    private var segments: [String] = []

    func startRecognition() async throws -> AsyncThrowingStream<String, Error> {
        // 💥 Simulate random errors
        if Bool.random() {
            throw SpeechError.recognizerUnavailable
        }

        isActive = true
        segments = []

        return AsyncThrowingStream { continuation in
            Task {
                for i in 1...5 {
                    guard isActive else { break }

                    // 💥 Simulate error during processing
                    if i == 3 && Bool.random() {
                        continuation.finish(
                            throwing: SpeechError.recognitionFailed(reason: "Network timeout"))
                            return
                    }

                    try? await Task.sleep(for: .seconds(1.5))
                    let segment = "Segment \(i) recognized. "
                    segments.append(segment)
                    continuation.yield(segment)
                }
                continuation.finish()
            }
        }
    }

    func stopRecognition() {
        isActive = false
    }
}

// UI layer - decides what to show
@MainActor
@Observable
class SpeechViewModel {
    var transcript = ""
    var isRecognizing = false
    var error: String?

    private let engine = SpeechEngine()

    func startRecording() {
        isRecognizing = true
        transcript = ""
        error = nil  // Clear previous error

        Task {
            // ✅ Guaranteed to run no matter how the function exits - success,
            // error, early return, whatever. Very similar to JavaScript's finally block.
            defer { isRecognizing = false }
            
            do {
                for try await segment in try await engine.startRecognition() {
                    transcript += segment
                }
            } catch let speechError as SpeechError {
                self.error = speechError.errorDescription
            } catch {
                self.error = "Unexpected error occurred"
            }
        }
    }

    func stopRecording() {
        Task {
            await engine.stopRecognition()
            isRecognizing = false
        }
    }
}
