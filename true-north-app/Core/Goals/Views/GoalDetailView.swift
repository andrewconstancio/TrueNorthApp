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
        var newShown = ""
        var newValid = ""
        
        let goalTitle = goal.title
        var goalIndex = 0
        var inputIndex = 0
        let inputChars = Array(newValue)
        let goalChars = Array(goalTitle)
        
        while goalIndex < goalChars.count && inputIndex < inputChars.count {
            let inputChar = inputChars[inputIndex]
            let goalChar = goalChars[goalIndex]
            
            if inputChar.lowercased() == goalChar.lowercased() {
                // Correct character typed
                newValid.append(inputChar)
                newShown.append(goalChar)
                goalIndex += 1
                inputIndex += 1
            } else if inputChar == " " {
                // Spacebar: treat as skip to next correct letter
                newValid.append(goalChar)
                newShown.append(goalChar)
                goalIndex += 1
                inputIndex += 1
            } else {
                // Incorrect character typed
                break
            }
        }

        goalText = newValid
        goalTextShown = newShown
    }
}

#Preview {
    GoalDetailView(
        goal: Goal.dummy,
        goalViewModel: GoalViewModel()
    )
}
