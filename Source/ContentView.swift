//
//  ContentView.swift
//  LearningSwift
//
//  Created by Maciej Sitkowski on 30/05/2025.
//

import SwiftUI

struct ContentView: View {
    @State private var viewModel = SpeechViewModel()

    var body: some View {
        VStack(spacing: 16) {
            HStack(alignment: .center) {
                Text("EchoNote")
                    .font(.largeTitle)

                Spacer()

                if viewModel.isRecognizing {

                    ProgressView()
                }
            }

            TextEditor(
                text: .constant(
                    viewModel.transcript.isEmpty
                        ? "Press 'Start Recording' to begin." : viewModel.transcript)
            )
            .frame(minHeight: 100, maxHeight: 200)
            .padding()
            .border(Color.gray.opacity(0.5), width: 1)
            .scrollContentBackground(.hidden)
            .disabled(true)

            if let errorText = viewModel.error {
                Text("Error: \(errorText)")
                    .foregroundColor(.red)
                    .padding(.vertical, 5)
            }

            Button(action: {
                if viewModel.isRecognizing {
                    viewModel.stopRecording()
                } else {
                    viewModel.startRecording()
                }
            }) {
                HStack {
                    Image(
                        systemName: viewModel.isRecognizing ? "stop.circle.fill" : "mic.circle.fill"
                    )
                    .font(.title2)
                    Text(viewModel.isRecognizing ? "Stop Recording" : "Start Recording")
                        .fontWeight(.semibold)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(viewModel.isRecognizing ? Color.red : Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
        .padding()
        .frame(minWidth: 400)
    }
}

#Preview {
    ContentView()
}
