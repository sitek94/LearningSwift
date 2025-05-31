//
//  HelloWorld.swift
//  LearningSwift
//
//  Created by Maciej Sitkowski on 30/05/2025.
//

import SwiftUI

struct HelloWorld: View {

    let names: [String] = ["Bilbo", "Frodo", "Sam"]

    func printNames() {
        for name in names {
            print(name)
        }
    }

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")

            Text("EchoNote Transcript:")
                .font(.headline)

            Button("Print names", action: printNames)

            Text("Your transcribed text will appear here...")
                .padding()
                .frame(minHeight: 100, alignment: .topLeading)
                .border(Color.gray)

            Button(action: {
            }) {
                Image(systemName: "mic.fill")
                Text("Start Recording")
            }
            .padding()
        }
        .padding()
    }
}

#Preview {
    HelloWorld()
}
