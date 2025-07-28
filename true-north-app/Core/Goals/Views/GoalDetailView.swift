import SwiftUI

struct GoalDetailView: View {
    /// The users inputed goal of this view.
    let goal: Goal
    
    /// The keyboard property observer.
    @StateObject private var keyboard = KeyboardObserver()
    
    /// The goal view model.
    @ObservedObject var goalViewModel: GoalViewModel
    
    /// The text overlay shown to the user.
    @State private var goalTextShown: String = ""
    
    /// The goals text.
    @State private var goalText: String = ""
     
    /// Should show the delete goal popover.
    @State private var showDeleteGoalPopover = false
    
    /// The goal notes text.
    @State private var goalNotes: String = ""
    
    /// Focus keyboard.
    @FocusState private var isKeyboardFocused: Bool
    
    /// Is the goal notes focused.
    @FocusState private var isGoalNotesFocused: Bool
    
    /// Dismiss environment view.
    @Environment(\.dismiss) var dismiss
    
    /// Is the goal update complete.
    private var isCompleted: Bool {
        goal.title.lowercased() == goalText.lowercased()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            goalStartedDate
            description
            header
            Spacer()
            goalTextField
            goalSteakCounter
            Spacer()
            addNotesButton
        }
        .scrollIndicators(.hidden)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showDeleteGoalPopover = true
                } label: {
                    Image(systemName: "trash")
                        .resizable()
                        .foregroundStyle(.primary)
                        .frame(width: 24, height: 24)
                }
            }
        }
        .onChange(of: goalText) { newValue in
            handleTextChange(newValue)
        }
        .sheet(isPresented: $showDeleteGoalPopover, content: {
            deleteGoal
                .presentationDetents([.fraction(0.4)])
        })
        .onAppear {
            isKeyboardFocused = true
        }
    }
    
    /// Start date of goal.
    private var goalStartedDate: some View {
        HStack {
            Spacer()
            Text("Started")
                .fontWeight(.bold)
            Text("Jan 1, 2021")
                .font(.caption)
        }
    }
    
    /// Header. Shows goal title and goal text update. 
    private var header: some View {
        VStack {
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
        }
        .padding(.top, 20)
        .onTapGesture {
            isKeyboardFocused.toggle()
        }
    }
    
    /// Goal description
    private var description: some View {
        Text(goal.description)
            .fontWeight(.medium)
            .padding(.top, 50)
    }
    
    /// Save goal update button.
    private var saveButton: some View {
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
    
    /// Text field for goal update.
    private var goalTextField: some View {
        TextField("", text: $goalText)
            .focused($isKeyboardFocused)
            .opacity(0)
    }
    
    /// Delete goal and goal history view.
    private var deleteGoal: some View {
        VStack(alignment: .leading) {
            Text("Delete habit and its history?")
                .font(.title3)
                .fontWeight(.bold)
            
            Spacer().frame(height: 32)
            
            VStack(spacing: 15) {
                Button {
                    showDeleteGoalPopover = false
                    if let goalId = goal.id {
                        Task {
                            do {
                                try await goalViewModel.deleteGoalAndHistory(for: goalId)
                                dismiss()
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                    }
                } label: {
                    Text("Delete habit and history")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(width: 340, height: 65)
                        .background(.yellow)
                        .clipShape(Capsule())
                }
                
                Button {
                    showDeleteGoalPopover = false
                } label: {
                    Text("Keep it")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(width: 340, height: 65)
                        .background(.gray)
                        .clipShape(Capsule())
                }
            }
        }
    }
    
    /// Goal streak conter.
    private var goalSteakCounter: some View {
        HStack {
            Spacer()
            VStack(spacing: 8) {
                Text("Streak")
                    .fontWeight(.bold)
                
                Text("2")
                    .font(.system(size: 90))
                    .fontWeight(.bold)
            }
            Spacer()
        }
    }
    
    /// Add notes button.
    private var addNotesButton: some View {
        ZStack(alignment: .topLeading) {
            if goalNotes.isEmpty && !isGoalNotesFocused {
                Text("Add Notes")
                    .bold()
                    .foregroundColor(Color.primary.opacity(0.2))
                    .padding(.top, 7)
            }

            TextEditor(text: $goalNotes)
                .focused($isGoalNotesFocused)
                .scrollContentBackground(.hidden)
                .frame(minHeight: 100)
                .accessibilityLabel("Goal description")
        }
        .padding()
        .frame(height: 100)
        .background(Color.gray.opacity(0.2).ignoresSafeArea())
        .clipShape(
            .rect(
                topLeadingRadius: 20,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: 20
            )
        )
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
                newValid.append(inputChar)
                newShown.append(goalChar)
                goalIndex += 1
                inputIndex += 1
            } else if inputChar == " " {
                newValid.append(goalChar)
                newShown.append(goalChar)
                goalIndex += 1
                inputIndex += 1
            } else {
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
