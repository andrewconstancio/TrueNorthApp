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
    @ObservedObject var goalDetailVM: GoalDetailViewModel
    
    /// Flag to show the edit view.
    @State private var showEditGoalSheet = false
    
    /// Flag to show the add note view.
    @State private var showAddNoteSheet = false
    
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
//    init(goal: Goal) {
//        self.goal = goal
//    }
    
    var body: some View {
        ZStack {
            confettiView
            mainContent
        }
//        .padding()
        .scrollIndicators(.hidden)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                addNoteButton
            }
            ToolbarItem(placement: .topBarTrailing) {
                editButton
            }
        }
        .onChange(of: goalDetailVM.goalReEntryText) {_, _ in
            goalDetailVM.handleGoalTextChange()
        }
        .sheet(isPresented: $showAddNoteSheet) {
            AddNoteView(goalDetailVM: goalDetailVM)
        }
        .sheet(isPresented: $showEditGoalSheet) {
            NavigationStack {
                GoalAddEditView(
                    goal: goal,
                    goalAddEditVM: GoalAddEditViewModel(
                        editGoal: goal,
                        firebaseService: goalDetailVM.firebaseService
                    )
                )
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
        .errorAlert(
            isPresented: $goalDetailVM.showAppError,
            error: goalDetailVM.appError
        )
        .hideKeyboardOnTap()
        
        // Show the retyping goal keyboard on appear.
        .onAppear {
            isKeyboardFocused = true
            
            Task {
                await goalDetailVM.fetchNotes()
            }
        }
        
        // Check to see if the goals daily saved was made.
        .task {
            await goalDetailVM.checkUpdated(
                for: goal,
                selectedDate: Date()
            )
        }
        .background(Color.backgroundPrimary.ignoresSafeArea())
    }
    
    /// Main Content.
    private var mainContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                goalMetadataView
                descriptionView
                directionsText
                goalInputView
                notes
                Spacer()
                
                if goalDetailVM.showSaveButton {
                    saveButton
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .padding(.horizontal)
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
    private var addNoteButton: some View {
        Button {
            showAddNoteSheet = true
        } label: {
            Text("Add Note")
                .font(FontManager.Bungee.regular.font(size: 14))
                .foregroundStyle(.spaceCadet)
        }
    }
    
    /// Pencil edit button for the goal.
    private var editButton: some View {
        Button {
            showEditGoalSheet = true
        } label: {
            Text("Edit")
                .font(FontManager.Bungee.regular.font(size: 14))
                .foregroundStyle(.sunglow)
//            Image(systemName: "pencil")
//                .resizable()
//                .foregroundStyle(.primary)
//                .frame(width: 16, height: 16)
        }
    }
    
    private var notes: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Notes")
                .font(FontManager.Bungee.regular.font(size: 12))
                .foregroundStyle(.textSecondary)
            
            ForEach(goalDetailVM.goalNotes, id: \.self) { note in
                VStack(spacing: 4) {
                    
                    Text(note.dateCreated.dateValue().formattedDateString)
                        .font(FontManager.Bungee.regular.font(size: 12))
                        .foregroundStyle(.textSecondary)
                    
                    ZStack(alignment: .leading) {
                        // Full-width background
                        UnevenRoundedRectangle(
                            cornerRadii: .init(
                                topLeading: 16,
                                bottomLeading: 16,
                                bottomTrailing: 0,
                                topTrailing: 16
                            )
                        )
                        .fill(.black.opacity(0.4))
                        .frame(maxWidth: .infinity)
                        
                        // Text on top
                        Text(note.note)
                            .font(FontManager.Bungee.regular.font(size: 14))
                            .foregroundStyle(.textPrimary)
                            .padding()
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.vertical, 2)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }


        }
    }
}

// TODO: Move this out

struct AddNoteView: View {
    /// The dismiss environment object.
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var goalDetailVM: GoalDetailViewModel
    
    @State private var noteText: String = ""
    
    var body: some View {
        VStack() {
            Spacer()
            
            Text("Add note")
                .font(FontManager.Bungee.regular.font(size: 22))
                .foregroundStyle(.textSecondary)
            
            ZStack {
                if noteText.isEmpty {
                    Text("So whats on your mind...")
                        .font(FontManager.Bungee.regular.font(size: 16))
                        .foregroundStyle(.red)
                }
                
                TextEditor(text: $noteText)
                    .font(FontManager.Bungee.regular.font(size: 16))
                    .foregroundStyle(.textBlack)
                    .scrollContentBackground(.hidden)
                    .textEditorStyle(.plain)
                    .frame(height: 350)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                    )
                    .padding()
            }
            
            Spacer()
            
            Button {
                Task {
                    await goalDetailVM.saveNote(note: noteText)
                    dismiss()
                }
            } label: {
                Text("Save!")
                    .font(FontManager.Bungee.regular.font(size: 18))
                    .foregroundStyle(.textPrimary)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(.utOrange)
                    .clipShape(Capsule())
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.backgroundPrimary.ignoresSafeArea())
    }
}

#Preview {
    NavigationStack {
        AddNoteView(goalDetailVM: GoalDetailViewModel(goal: Goal.dummy, firebaseService: FirebaseService()))
    }
}

#Preview {
    NavigationStack {
        GoalDetailView(
            goal: Goal.dummy,
            goalDetailVM: GoalDetailViewModel(goal: Goal.dummy, firebaseService: FirebaseService())
        )
    }
}
