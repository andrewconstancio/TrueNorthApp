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
    
    /// The text for a new note.
    @State private var noteText = ""
    
    /// Flag to show the notes action sheet.
    @State private var showNotesActionSheet = false
    
    /// Flag to show the delete not activity indicator.
    @State private var showDeleteNoteActivityIndicator = false
    
    @State var selectedNotesID: String?
    
    /// Flag if the entered text matches the goals total.
    private var isGoalCompleted: Bool {
        goal.title.lowercased() == goalDetailVM.goalReEntryText.lowercased() || goalDetailVM.dailyEntryCompleted
    }
    
    var body: some View {
        ZStack {
            mainContent
            confettiView
            
            if goalDetailVM.showSaveButton {
                VStack {
                    Spacer()
                    saveButton
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            
            newNote
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.backgroundPrimary.ignoresSafeArea())
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
        .sheet(isPresented: $showNotesActionSheet) {
            noteActionGoalSheet
        }
        .errorAlert(
            isPresented: $goalDetailVM.showAppError,
            error: goalDetailVM.appError
        )
        .generalAlert(
            title: "Are you sure you want to delete this note?",
            isPresented: $showDeleteNoteActivityIndicator,
            primaryButton: ("Delete", .destructive, {
                guard let noteID = selectedNotesID else { return }
                Task {
                    await goalDetailVM.deleteNote(noteID: noteID)
                }
            }),
            secondaryButton: ("Cancel", .cancel, {} )
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
            await goalDetailVM.fetchNotes()
        }
        
        .onChange(of: showAddNoteSheet) { _, newValue in
            if newValue == false {
                noteText = ""
            }
        }
    }
    
    /// Main Content.
    private var mainContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                goalMetadataView
                descriptionView
                directionsText
                goalInputView
                goalNotes
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
            }
        } label: {
            Text("Save!")
                .font(FontManager.Bungee.regular.font(size: 22))
                .foregroundStyle(.textPrimary)
                .frame(height: 65)
                .frame(maxWidth: .infinity)
                .background(.utOrange)
                .clipShape(Capsule())
                .padding(.horizontal)
        }
    }
    
    /// Pencil edit button for the goal.
    private var addNoteButton: some View {
        Button {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            withAnimation(.spring()) {
                showAddNoteSheet = true
            }
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
        }
    }
    
    private var newNote: some View {
        CenterPopup(
            isPresented: $showAddNoteSheet,
            title: "New Note",
            backgroundColor: .backgroundLighter
        ) {
            VStack(spacing: 20) {
                // Text editor with improved styling
                ZStack(alignment: .topLeading) {
                    // Background with subtle shadow
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.black.opacity(0.3))
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                    
                    // Placeholder text
                    if noteText.isEmpty {
                        Text("So what's on your mind...")
                            .font(FontManager.Bungee.regular.font(size: 16))
                            .foregroundStyle(.textSecondary)
                            .padding(.top, 16)
                            .padding(.leading, 16)
                            .allowsHitTesting(false)
                    }
                    
                    // Text editor
                    TextEditor(text: $noteText)
                        .font(FontManager.Bungee.regular.font(size: 16))
                        .foregroundStyle(.textPrimary)
                        .scrollContentBackground(.hidden)
                        .textEditorStyle(.plain)
                        .padding(12)
                        .background(Color.clear)
                }
                .frame(maxWidth: .infinity, minHeight: 160)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            noteText.isEmpty ? Color.textPrimary.opacity(0.2) : Color.sunglow.opacity(0.5),
                            lineWidth: noteText.isEmpty ? 1 : 2
                        )
                )
                .animation(.easeInOut(duration: 0.2), value: noteText.isEmpty)
                
                HStack {
                    Spacer()
                    Text("\(noteText.count) characters")
                        .font(FontManager.Bungee.regular.font(size: 10))
                        .foregroundStyle(.textSecondary)
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    // Cancel button
                    Button {
                        let impact = UIImpactFeedbackGenerator(style: .light)
                        impact.impactOccurred()
                        showAddNoteSheet = false
                    } label: {
                        Text("Cancel")
                            .font(FontManager.Bungee.regular.font(size: 16))
                            .foregroundStyle(.textSecondary)
                            .frame(height: 55)
                            .frame(maxWidth: .infinity)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(Color.textSecondary.opacity(0.3), lineWidth: 1)
                            )
                    }
                    
                    // Save button with better feedback
                    Button {
                        let impact = UIImpactFeedbackGenerator(style: .medium)
                        impact.impactOccurred()
                        Task {
                            await goalDetailVM.saveNote(note: noteText)
                            showAddNoteSheet = false
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Text("Save")
                                .font(FontManager.Bungee.regular.font(size: 18))
                            
                            if !noteText.isEmpty {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 18))
                            }
                        }
                        .foregroundStyle(.textPrimary)
                        .frame(height: 55)
                        .frame(maxWidth: .infinity)
                        .background(
                            noteText.isEmpty
                            ? Color.gray.opacity(0.3)
                            : Color.utOrange
                        )
                        .clipShape(Capsule())
                        .shadow(
                            color: noteText.isEmpty ? .clear : .utOrange.opacity(0.3),
                            radius: 8,
                            x: 0,
                            y: 4
                        )
                        .scaleEffect(noteText.isEmpty ? 0.98 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: noteText.isEmpty)
                    }
                    .disabled(noteText.isEmpty)
                }
            }
            .padding(.top, 8)
            .frame(maxHeight: 360)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }
    
    private var goalNotes: some View {
        ForEach(goalDetailVM.goalNotes) { note in
            VStack(alignment: .leading, spacing: 4) {
                
                HStack {
                    Text(note.dateCreated.dateValue().formattedDateString)
                        .font(FontManager.Bungee.regular.font(size: 12))
                        .foregroundStyle(.textSecondary)
                        .padding(.leading, 4)
                    Spacer()
                    Button {
                        selectedNotesID = note.id
                        showNotesActionSheet = true
                    } label: {
                        Image(systemName: "ellipsis")
                            .resizable()
                            .scaledToFit()      // ensures proper aspect ratio
                            .frame(width: 20, height: 20)
                            .foregroundStyle(.textSecondary)
                            .padding(8)         // increases tappable area
                    }
                    .buttonStyle(.plain)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }

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
                    .frame(maxWidth: .infinity, minHeight: 44) // give it a default height

                    // Text on top
                    Text(note.note)
                        .font(FontManager.Bungee.regular.font(size: 14))
                        .foregroundStyle(.textPrimary)
                        .padding()
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
    
    /// Delete Goal Sheet.
    private var noteActionGoalSheet: some View {
        VStack(alignment: .leading, spacing: 32) {
            Button {
                showDeleteNoteActivityIndicator = true
            } label: {
                Text("Delete")
                    .font(FontManager.Bungee.regular.font(size: 14))
                    .foregroundStyle(.textPrimary)
                    .frame(width: 340, height: 65)
                    .background(.utOrange)
                    .clipShape(Capsule())
            }
        }
        .padding()
        .presentationDetents([.fraction(0.2)])
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.7))
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
