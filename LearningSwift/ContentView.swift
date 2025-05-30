//
//  ContentView.swift
//  LearningSwift
//
//  Created by Maciej Sitkowski on 30/05/2025.
//

import SwiftUI

struct ContentView: View {
    
    var names: [String] = ["Maciej", "Kamil", "Krystian"]
    
    func printNames() -> Void {
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
            
            Button("Print names", action: printNames)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
