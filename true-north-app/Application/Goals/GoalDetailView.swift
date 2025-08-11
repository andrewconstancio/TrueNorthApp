import SwiftUI
import Lottie

struct GoalDetailView: View {
    /// The users goal.
    let goal: Goal
    
    /// The dismiss environment object.
    @Environment(\.dismiss) private var dismiss
    
    /// The goal details view model.
    @StateObject private var vm = GoalDetailViewModel()
    
    /// Flag to show the delete goal popover.
    @State private var showDeleteGoalPopover = false
    
    /// Flag to play the success animation when completing a daily entry.
    @State private var playSuccessAnimation = false
    
    /// Flag if the keyboard is focused.
    @FocusState private var isKeyboardFocused: Bool
    
    /// Flag if the entered text matches the goals total.
    private var isGoalCompleted: Bool {
        goal.title.lowercased() == vm.goalTitleInputText.lowercased() || vm.dailyEntryCompleted
    }
    
    var body: some View {
        ZStack {
            confettiView
            mainContent
        }
        .task {
            await vm.checkUpdated(
                for: goal,
                selectedDate: Date()
            )
        }
        .padding()
        .scrollIndicators(.hidden)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                deleteButton
            }
        }
        .onChange(of: vm.goalTitleInputText) {_, _ in
            vm.handleGoalTextChange(goal.title)
        }
        .sheet(isPresented: $showDeleteGoalPopover) {
            deleteGoalSheet
        }
        .background(Color.backgroundPrimary.ignoresSafeArea())
        .errorAlert(isPresented: $vm.showAppError, error: vm.appError)
        .hideKeyboardOnTap()
        
        // Show the retyping goal keyboard on appear.
        .onAppear {
            isKeyboardFocused = true
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
            
            if vm.savingState {
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
            if let endDate = goal.endDate {
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
            
            Text("Streak: \(goal.streak)")
                .font(FontManager.Bungee.regular.font(size: 16))
                .foregroundStyle(.sunglow)
        }
    }
    
    /// Description.
    private var descriptionView: some View {
        Text(goal.description)
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
            Text(goal.title)
                .font(FontManager.Bungee.regular.font(size: 26))
                .foregroundStyle(isGoalCompleted ? .textPrimary : .textPrimary.opacity(0.3))
            
            if !isGoalCompleted {
                MultilineTextField(text: $vm.goalTitleInputText)
                    .focused($isKeyboardFocused)
                    .frame(width: 350)
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
                
                guard let goalId = goal.id else { return }
                await vm.saveProgress(for: goalId)
                playSuccessAnimation = true
                vm.savingState = false
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
    
    /// Trash can delete button for the goal.
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
    
    /// Delete Goal Sheet.
    private var deleteGoalSheet: some View {
        VStack(alignment: .leading, spacing: 32) {
            Text("Delete habit and its history?")
                .font(FontManager.Bungee.regular.font(size: 16))
                .foregroundStyle(.textPrimary)
            
            VStack(spacing: 15) {
                // Delete the goal button.
                Button {
                    showDeleteGoalPopover = false
                    Task {
                        await vm.deleteGoalAndHistory(for: goal)
                        dismiss()
                    }
                } label: {
                    Text("Delete habit and history")
                        .font(FontManager.Bungee.regular.font(size: 14))
                        .foregroundStyle(.textBlack)
                        .frame(width: 340, height: 65)
                        .background(.sunglow)
                        .clipShape(Capsule())
                }
                
                
                // Keep the goal button.
                Button {
                    showDeleteGoalPopover = false
                } label: {
                    Text("Keep it")
                        .font(FontManager.Bungee.regular.font(size: 14))
                        .foregroundColor(.textBlack)
                        .frame(width: 340, height: 65)
                        .background(.gray)
                        .clipShape(Capsule())
                }
            }
        }
        .padding()
        .presentationDetents([.fraction(0.4)])
        .background(Color.backgroundLighter)
    }
}

#Preview {
    GoalDetailView(
        goal: Goal.dummy
    )
}
