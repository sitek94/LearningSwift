//
//  StateAndDataFlow.swift
//  LearningSwift
//
//  Created by Maciej Sitkowski on 30/05/2025.
//

import SwiftUI

struct StateAndDataFlow: View {
    @State private var isRecording: Bool = false
    @State private var currentTranscript: String = "Tap 'Record' to start..."

    var body: some View {
        VStack {
            Text("EchoNote Transcript:").font(.headline)

            TextEditor(text: $currentTranscript)
                .font(.system(size: 16))
                .padding()
                .border(.gray)
                .scrollContentBackground(.hidden)

            HStack {
                RecordingButton(color: Color.blue, isRecording: $isRecording)
                RecordingButton(color: Color.red, isRecording: $isRecording)
            }

        }
        .padding()
        .onChange(of: isRecording) { oldValue, newValue in
            print("isRecording changed from \(oldValue) to \(newValue)")

            if newValue {
                currentTranscript = "Recording..."
            } else {
                currentTranscript = "Tap 'Record' to start..."
            }
        }
    }
}

private struct RecordingButton: View {
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
    StateAndDataFlow()
}
