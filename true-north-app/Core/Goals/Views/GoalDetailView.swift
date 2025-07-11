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
    @StateObject private var keyboard = KeyboardObserver()
    @State private var goalTextShown: String = ""
    @State private var goalText: String = ""
    @FocusState private var isKeyboardFocused: Bool
    @Environment(\.dismiss) var dismiss
    
    private var isCompleted: Bool {
        goal.title.lowercased() == goalText.lowercased()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Spacer()
            
            ZStack(alignment: .topLeading) {
                Text(goal.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.gray.opacity(0.3))
                    .multilineTextAlignment(.leading)
                
                Text(goalTextShown)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("Type the goal title")
                .font(.caption)
                .padding(.bottom, 10)
            
            Text(goal.description)
                .fontWeight(.medium)
            
            Spacer()
            
            TextField("", text: $goalText)
                .focused($isKeyboardFocused)
                .opacity(0)
            
            Button {
                if let goalId = goal.id {
                    Task {
                        try? await goalViewModel.saveProgress(for: goalId)
                    }
                    dismiss()
                }
            } label: {
                Text("Save")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 340, height: 65)
                    .background(isCompleted ? Color.themeColor : Color.black.opacity(0.4))
                    .clipShape(Capsule())
                    .padding()
                    .animation(.easeOut(duration: 0.25), value: keyboard.keyboardHeight)
                    .opacity(isCompleted ? 1 : 0.5)
            }
        }
        .toolbar(.hidden, for: .tabBar)
        .onChange(of: goalText) { newValue in
            // Impact occurred
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            handleTextChange(newValue)
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
        var prefix = ""
        for i in 0..<min(newValue.count, goal.title.count) {
            let currentChar = newValue[newValue.index(newValue.startIndex, offsetBy: i)]
            let expectedChar = goal.title[goal.title.index(goal.title.startIndex, offsetBy: i)]
            
            if currentChar.lowercased() == expectedChar.lowercased() {
                validPrefix += String(currentChar)
                prefix += String(expectedChar)
            } else {
                break
            }
        }
        
        // Update the text field to only contain valid characters
        goalText = validPrefix
        goalTextShown = prefix
    }
}

//#Preview {
//    GoalDetailView(goal: Goal.dummy)
//}
