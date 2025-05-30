//
//  ContentView.swift
//  LearningSwift
//
//  Created by Maciej Sitkowski on 30/05/2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
            TextEditor(text: /*@START_MENU_TOKEN@*/ .constant("Placeholder") /*@END_MENU_TOKEN@*/)
                .padding()
                .border(.gray)
                .scrollContentBackground(.hidden)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
