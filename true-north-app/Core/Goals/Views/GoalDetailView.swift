import SwiftUI

struct GoalDetailView: View {
    let goal: Goal
    let selectedDate: Date
    
    ///Environment
    @Environment(\.dismiss) var dismiss
    @StateObject private var keyboard = KeyboardObserver()
    @StateObject private var viewModel = GoalDetailViewModel()
    
    /// State
    @State private var goalTextShown: String = ""
    @State private var goalText: String = ""
    @State private var goalNotes: String = ""
    @State private var showDeleteGoalPopover = false
    @State private var showText = false
    @State private var showSavingState: Bool = false
    @State private var animateBorder = false
    @State private var completed: Bool = false
    @State private var currentError: AppError?
    @State private var showingErrorAlert = false
    
    /// Focus State
    @FocusState private var isKeyboardFocused: Bool
    @FocusState private var isGoalNotesFocused: Bool
    
    /// Local vars
    private var typedInGoal: Bool {
        goal.title.lowercased() == goalText.lowercased()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            goalStartedDateView
            descriptionView
            directionsText
            headerView
            Spacer()
            if showSavingState {
                saveButton
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .task {
            await getGoalDetails()
        }
        .onAppear {
            animateBorder = true
        }
        .hideKeyboardOnTap()
        .padding()
        .scrollIndicators(.hidden)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                deleteButton
            }
        }
        .onChange(of: typedInGoal) { newValue in
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                showSavingState = true
            }
        }
        .onChange(of: goalText) { newValue in
            handleTextChange(newValue)
        }
        .sheet(isPresented: $showDeleteGoalPopover) {
            deleteGoalSheet
                .presentationDetents([.fraction(0.4)])
        }
        .background(Color.backgroundPrimary.ignoresSafeArea())
        .errorAlert(isPresented: $showingErrorAlert, error: currentError)
    }
    
    private func getGoalDetails() async {
        do {
            completed = try await viewModel.checkUpdated(for: goal, selectedDate: selectedDate)
        } catch {
            currentError = .networkError("Failed to fetch data.")
            showingErrorAlert = true
        }
    }
    
    private var goalStartedDateView: some View {
        HStack {
            Text(goal.dateCreated.dateValue().formattedDateString)
                .font(FontManager.Bungee.regular.font(size: 14))
                .foregroundStyle(.sunglow)
            Spacer()
            Text("Streak: \(goal.streak)")
                .font(FontManager.Bungee.regular.font(size: 14))
                .foregroundStyle(.sunglow)
        }
    }
    
    private func completeGoal() {
        Task {
            do {
                guard let goalId = goal.id else { return }
                try await viewModel.saveProgress(for: goalId)
            } catch {
                currentError = .customError(message: "Failed to save progress. Please try again later.")
                showingErrorAlert = true
            }
            showSavingState = false
        }
    }
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .topLeading) {
                    Text(goal.title)
                        .font(FontManager.Bungee.regular.font(size: 26))
                        .foregroundStyle(typedInGoal || completed ? .textPrimary : .textPrimary.opacity(0.3))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 12)
                    
                    TextField("", text: $goalText)
                        .focused($isKeyboardFocused)
                        .font(FontManager.Bungee.regular.font(size: 26))
                        .foregroundStyle(.textPrimary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 12)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .padding(.top, 20)
            .padding(.horizontal)
            .padding(.bottom, 12)
            .background(.spaceCadet)
            .cornerRadius(10)
            .opacity(showText ? 1 : 0)
            .onAppear {
                withAnimation(.easeIn(duration: 0.5)) {
                    showText = true
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private var saveButton: some View {
        Button {
            completeGoal()
        } label: {
            Text("Save!")
                .font(FontManager.Bungee.regular.font(size: 22))
                .foregroundStyle(.textPrimary)
                .frame(height: 65)
                .frame(maxWidth: .infinity)
                .background(.utOrange)
                .clipShape(Capsule())
        }
    }
    
    private var descriptionView: some View {
        Text(goal.description)
            .font(FontManager.Bungee.regular.font(size: 16))
            .foregroundStyle(.textPrimary)
    }
    
    private var directionsText: some View {
        Text("Retype the goal to cement the commitment.")
            .font(FontManager.Bungee.regular.font(size: 12))
            .foregroundStyle(.textSecondary)
    }
    
    private var deleteButton: some View {
        Button {
            showDeleteGoalPopover = true
        } label: {
            Image(systemName: "trash")
                .resizable()
                .foregroundStyle(.primary)
                .frame(width: 18, height: 22)
        }
    }
    
    private var deleteGoalSheet: some View {
        VStack(alignment: .leading, spacing: 32) {
            Text("Delete habit and its history?")
                .font(.title3)
                .fontWeight(.bold)
            
            VStack(spacing: 15) {
                deleteConfirmButton
                keepGoalButton
            }
        }
        .padding()
    }
    
    private var deleteConfirmButton: some View {
        Button {
            showDeleteGoalPopover = false
            deleteGoal()
        } label: {
            Text("Delete habit and history")
                .font(.headline)
                .foregroundColor(.black)
                .frame(width: 340, height: 65)
                .background(.yellow)
                .clipShape(Capsule())
        }
    }
    
    private var keepGoalButton: some View {
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
    
    private var goalStreakCounter: some View {
        HStack {
            Spacer()
            VStack(spacing: 8) {
                Text("Streak")
                    .fontWeight(.bold)
                
                Text("\(goal.streak)")
                    .font(.system(size: 60))
                    .fontWeight(.bold)
            }
            Spacer()
        }
    }
    
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
                .accessibilityLabel("Goal notes")
        }
        .padding()
        .frame(height: 100)
        .background(Color.gray.opacity(0.2))
        .clipShape(
            .rect(
                topLeadingRadius: 20,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: 20
            )
        )
    }
    
    private func deleteGoal() {
        guard let goalId = goal.id else { return }
        
        Task {
            do {
                try await viewModel.deleteGoalAndHistory(for: goalId)
                dismiss()
            } catch {
                print("Error deleting goal: \(error.localizedDescription)")
            }
        }
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
        selectedDate: Date()
    )
}
