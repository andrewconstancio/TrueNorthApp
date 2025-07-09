//
//  GoalDetailView.swift
//  true-north-app
//
//  Created by Andrew Constancio on 7/8/25.
//

import SwiftUI

struct GoalDetailView: View {
    let goal: Goal
    @ObservedObject var goalViewModel: GoalViewModel
    @State private var goalTextShown: String = ""
    @State private var goalText: String = ""
    @FocusState private var isKeyboardFocused: Bool
    @Environment(\.dismiss) var dismiss
    
    private var isCompleted: Bool {
        goal.title == goalText
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .leading) {
                Text(goal.title)
                    .font(.largeTitle)
                    .foregroundStyle(.gray.opacity(0.3))
                
                Text(goalTextShown)
                    .font(.largeTitle)
                    .foregroundStyle(.primary)
            }
            
            Text("Type the goal title")
                .font(.caption)
                .padding(.bottom, 10)
            
            
            Text(goal.description)
                .fontWeight(.medium)
            
            Spacer()
            Spacer()
            
            TextField("", text: $goalText)
                .focused($isKeyboardFocused)
                .opacity(0)
        }
        .toolbar(.hidden, for: .tabBar)
        .onChange(of: goalText) { newValue in
            handleTextChange(newValue)
        }
        .onChange(of: isCompleted) { newValue in
            if newValue {
                isKeyboardFocused = false
                if let goalId = goal.id {
                    Task {
                        try? await goalViewModel.saveProgress(for: goalId)
                    }
                    dismiss()
                }
            }
        }
        .onAppear {
            isKeyboardFocused = true
        }
        .padding()
    }
    
    private func handleTextChange(_ newValue: String) {
        let expectedPrefix = String(goal.title.prefix(newValue.count))
        
        // If the new text matches the expected prefix, update both values
        if newValue == expectedPrefix {
            goalTextShown = newValue
            return
        }
        
        // If it doesn't match, find the longest valid prefix
        var validPrefix = ""
        for i in 0..<min(newValue.count, goal.title.count) {
            let currentChar = newValue[newValue.index(newValue.startIndex, offsetBy: i)]
            let expectedChar = goal.title[goal.title.index(goal.title.startIndex, offsetBy: i)]
            
            if currentChar == expectedChar {
                validPrefix += String(currentChar)
            } else {
                break
            }
        }
        
        // Update the text field to only contain valid characters
        goalText = validPrefix
        goalTextShown = validPrefix
    }
}

//#Preview {
//    GoalDetailView(goal: Goal.dummy)
//}
