//
//  ObservableExampleView.swift
//  LearningSwift
//
//  Created by Maciej Sitkowski on 30/05/2025.
//
import Observation
import SwiftUI

@Observable
class NewSpeechEngine {
    var isRecording: Bool = false
    var transcript: String = ""
}

struct ObservableExampleView: View {
    @State private var speechEngine = NewSpeechEngine()

    var body: some View {
        VStack {
            Text("EchoNote Transcript:").font(.headline)

            TextEditor(text: $speechEngine.transcript)
                .font(.system(size: 16))
                .padding()
                .border(.gray)
                .scrollContentBackground(.hidden)

            HStack {
                RecordingButtonView(color: Color.blue, isRecording: $speechEngine.isRecording)
                RecordingButtonView(color: Color.red, isRecording: $speechEngine.isRecording)
            }

        }
        .padding()
        .onChange(of: speechEngine.isRecording) { oldValue, newValue in
            print("isRecording changed from \(oldValue) to \(newValue)")

            if newValue {
                speechEngine.transcript = "Recording..."
            } else {
                speechEngine.transcript = "Tap 'Record' to start..."
            }
        }
    }
}

private struct RecordingButtonView: View {
    let color: Color
    @Binding var isRecording: Bool

    var body: some View {
        Button(action: {
            isRecording.toggle()  // Modifies the @State variable
        }) {
            HStack {
                Image(systemName: isRecording ? "stop.circle.fill" : "mic.fill")
                Text(isRecording ? "Stop Recording" : "Start Recording")
                    .font(Font.system(size: 16))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }.background(color)
            .cornerRadius(16)
    }
}

#Preview {
    ObservableExampleView()
}
