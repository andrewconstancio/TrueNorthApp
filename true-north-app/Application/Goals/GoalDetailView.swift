import SwiftUI
import Lottie

/// Display the details of a goal and has the functionality for the user to make a daily progress re-entry on the goal.
struct GoalDetailView: View {
    /// The users goal.
    var goal: Goal
    
    /// The dismiss environment object.
    @Environment(\.dismiss) private var dismiss
    
    /// The auth view model. 
    @EnvironmentObject var authVM: AuthViewModel
    
    /// The goal details view model.
    @StateObject private var goalDetailVM: GoalDetailViewModel
    
    /// Flag to show the edit view.
    @State private var showEditGoalSheet = false
    
    /// Flag to play the success animation when completing a daily entry.
    @State private var playSuccessAnimation = false
    
    /// Flag if the keyboard is focused.
    @FocusState private var isKeyboardFocused: Bool
    
    /// Flag if the entered text matches the goals total.
    private var isGoalCompleted: Bool {
        goal.title.lowercased() == goalDetailVM.goalReEntryText.lowercased() || goalDetailVM.dailyEntryCompleted
    }
    
    /// The intializer for this view.
    /// - Parameter goal: The user goal to be displayed.
    init(goal: Goal) {
        self.goal = goal
        self._goalDetailVM = StateObject(
            wrappedValue: GoalDetailViewModel(goal: goal)
        )
    }
    
    var body: some View {
        ZStack {
            confettiView
            mainContent
        }
        .padding()
        .scrollIndicators(.hidden)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                editButton
            }
        }
        .onChange(of: goalDetailVM.goalReEntryText) {_, _ in
            goalDetailVM.handleGoalTextChange()
        }
        .sheet(isPresented: $showEditGoalSheet) {
            NavigationStack {
                GoalAddEditView(goal: goal)
                    .onDisappear {
                        guard let id = goal.id else {
                            return
                        }
                        Task {
                            let exist = await goalDetailVM.refreshGoal(id)
                            
                            // If it doesn't exist anymore dismiss the view.
                            if !exist {
                                dismiss()
                            }
                        }
                    }
            }
        }
        .background(Color.backgroundPrimary.ignoresSafeArea())
        .errorAlert(
            isPresented: $goalDetailVM.showAppError,
            error: goalDetailVM.appError
        )
        .hideKeyboardOnTap()
        
        // Show the retyping goal keyboard on appear.
        .onAppear {
            isKeyboardFocused = true
        }
        
        // Check to see if the goals daily saved was made.
        .task {
            await goalDetailVM.checkUpdated(
                for: goal,
                selectedDate: Date()
            )
        }
    }
    
    /// Main Content.
    private var mainContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            goalMetadataView
            descriptionView
            directionsText
            goalInputView
            Spacer()
            
            if goalDetailVM.showSaveButton {
                saveButton
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }
    
    /// Confetti Animation.
    @ViewBuilder
    private var confettiView: some View {
        if playSuccessAnimation {
            LottieView(animation: .named("Success"))
                .playbackMode(.playing(.toProgress(1, loopMode: .playOnce)))
                .animationDidFinish { completed in
                    if completed {
                        playSuccessAnimation = false
                    }
                }
        }
    }
    
    /// Goal Metadata.
    private var goalMetadataView: some View {
        HStack {
            if let endDate = goalDetailVM.goal.endDate {
                HStack(spacing: 4) {
                    Text("End Date:")
                        .font(FontManager.Bungee.regular.font(size: 14))
                        .foregroundStyle(.textSecondary)
                    
                    Text(endDate.formattedDateString)
                        .font(FontManager.Bungee.regular.font(size: 16))
                        .foregroundStyle(.sunglow)
                }
            }
            
            Spacer()
            
            Text("Streak: \(goalDetailVM.goal.streak)")
                .font(FontManager.Bungee.regular.font(size: 16))
                .foregroundStyle(.sunglow)
        }
    }
    
    /// Description.
    private var descriptionView: some View {
        Text(goalDetailVM.goal.description)
            .font(FontManager.Bungee.regular.font(size: 18))
            .foregroundStyle(.textPrimary)
    }
    
    /// Directions.
    private var directionsText: some View {
        Text("Retype the goal to cement the commitment.")
            .font(FontManager.Bungee.regular.font(size: 12))
            .foregroundStyle(.textSecondary)
    }
    
    /// Goal Input View.
    private var goalInputView: some View {
        ZStack(alignment: .topLeading) {
            Text(goalDetailVM.goal.title)
                .font(FontManager.Bungee.regular.font(size: 26))
                .foregroundStyle(isGoalCompleted ? .textPrimary : .textPrimary.opacity(0.3))
            
            if !isGoalCompleted {
                MultilineTextField(text: $goalDetailVM.goalReEntryText)
                    .focused($isKeyboardFocused)
                    .frame(width: 350)
                    .padding(.leading, -12)
            }
        }
        .frame(width: 350, alignment: .leading)
        .padding(.top, 20)
        .padding(.bottom, 12)
        .cornerRadius(10)
    }
    
    /// Save the daily goal update button.
    private var saveButton: some View {
        Button {
            Task {
                let impact = UIImpactFeedbackGenerator(style: .medium)
                impact.impactOccurred()
                
                guard let goalId = goalDetailVM.goal.id else { return }
                await goalDetailVM.saveProgress(for: goalId)
                playSuccessAnimation = true
                goalDetailVM.showSaveButton = false
                dismiss()
            }
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
    
    /// Pencil edit button for the goal.
    private var editButton: some View {
        Button {
            showEditGoalSheet = true
        } label: {
            Image(systemName: "pencil")
                .resizable()
                .foregroundStyle(.primary)
                .frame(width: 16, height: 16)
        }
    }
}

#Preview {
    NavigationStack {
        GoalDetailView(
            goal: Goal.dummy
        )
    }
}
