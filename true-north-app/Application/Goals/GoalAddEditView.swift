import SwiftUI
import Firebase

/// Displays the form to add or edit a goal by the user. 
struct GoalAddEditView: View {
    
    /// The goal passed in to add / edit.
    let goal: Goal?
    
    /// The goal view model.
    @ObservedObject var goalAddEditVM: GoalAddEditViewModel
    
    /// The dismiss environment object.
    @Environment(\.dismiss) private var dismiss
    
    /// Flag if the description is focused.
    @FocusState private var isDescriptionFocused: Bool
    
    /// Flag to show the delete goal popover.
    @State private var showDeleteGoalPopover = false

    var body: some View {
        content
    }
    
    /// The main content of the new goal form.
    var content: some View {
        ScrollView {
            LazyVStack(spacing: 24) {
                goalBasicInfoSection
                goalTargetDateSection
                goalCategorySection
            }
            .padding()
            .padding(.bottom, 60)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            if goal != nil {
                ToolbarItem(placement: .topBarLeading) {
                    deleteButton
                }
                ToolbarItem(placement: .topBarTrailing) {
                    updateButton
                }
            } else {
                ToolbarItem(placement: .topBarTrailing) {
                    saveButton
                }
            }
        }
        .sheet(isPresented: $showDeleteGoalPopover) {
            deleteGoalSheet
        }
        .background(.backgroundPrimary)
        .hideKeyboardOnTap()
    }
    
    /// The goals title.
    var goalBasicInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Goal Details")
            
            VStack(alignment: .leading, spacing: 12) {
                ZStack(alignment: .topLeading) {
                    if goalAddEditVM.goalForm.name.isEmpty {
                        Text("What do you want to achieve?")
                            .font(FontManager.Bungee.regular.font(size: 16))
                            .foregroundStyle(.textPrimary.opacity(0.2))
                    }
                    
                    TextField("", text: $goalAddEditVM.goalForm.name)
                        .font(FontManager.Bungee.regular.font(size: 16))
                        .foregroundStyle(.textPrimary)
                        .frame(minHeight: 20)
                        .accessibilityLabel("Goal name")
                }
                .padding()
                
                Divider()
                
                ZStack(alignment: .topLeading) {
                    if goalAddEditVM.goalForm.description.isEmpty && !isDescriptionFocused {
                        Text("Add a detailed description of your goal...")
                            .font(FontManager.Bungee.regular.font(size: 16))
                            .foregroundStyle(.textPrimary.opacity(0.2))
                            .padding(.top, 8)
                            .padding(.horizontal, 4)
                    }

                    TextEditor(text: $goalAddEditVM.goalForm.description)
                        .font(FontManager.Bungee.regular.font(size: 16))
                        .foregroundStyle(.textPrimary)
                        .textEditorStyle(.plain)
                        .focused($isDescriptionFocused)
                        .scrollContentBackground(.hidden)
                        .frame(minHeight: 80)
                        .accessibilityLabel("Goal description")
                }
                .padding(.horizontal, 11)
            }
            .modifier(FormSection(tintColor: goalAddEditVM.goalForm.selectedColor))
        }
    }

    
    /// The goals target complete date.
    var goalTargetDateSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Timeline")
            
            VStack(spacing: 16) {
                if !goalAddEditVM.goalForm.isEndless {
                    HStack {
                        Text("Target Date")
                            .font(FontManager.Bungee.regular.font(size: 16))
                            .foregroundStyle(.textPrimary)
                        Spacer()
                        
                        HStack {
                            Text(goalAddEditVM.goalForm.endDate.formattedDateString)
                                .font(FontManager.Bungee.regular.font(size: 14))
                                .foregroundStyle(.textPrimary)

                            Image(systemName: "pencil")
                        }
                        .overlay {
                            DatePicker(
                                "",
                                selection: $goalAddEditVM.goalForm.endDate,
                                displayedComponents: .date
                            )
                            .labelsHidden()
                            .colorMultiply(Color.clear)
                            .tint(.black)
                        }
                    }
                }
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("No Deadline")
                            .font(FontManager.Bungee.regular.font(size: 16))
                            .foregroundStyle(.textPrimary)
                        Text("Work on this goal indefinitely")
                            .font(FontManager.Bungee.regular.font(size: 12))
                            .foregroundStyle(.textPrimary)
                    }
                    
                    Spacer()
                    
                    Toggle("", isOn: $goalAddEditVM.goalForm.isEndless)
                        .labelsHidden()
                }
            }
            .padding()
            .modifier(FormSection(tintColor: goalAddEditVM.goalForm.selectedColor))
        }
    }
    
    /// The goals category.
    var goalCategorySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Category")
            
            HStack {
                Text("Type")
                    .font(FontManager.Bungee.regular.font(size: 16))
                    .foregroundStyle(.textPrimary)
                
                Spacer()
                
                Menu {
                    Picker(selection: $goalAddEditVM.goalForm.category) {
                        ForEach(GoalCategories.allCases, id: \.self) { category in
                            Text(category.rawValue.capitalized)
                                .tag(category.rawValue)
                        }
                    } label: {}
                } label: {
                    Text(goalAddEditVM.goalForm.category)
                        .font(FontManager.Bungee.regular.font(size: 14))
                        .foregroundStyle(.textPrimary)
                }
            }
            .padding()
            .modifier(FormSection(tintColor: goalAddEditVM.goalForm.selectedColor))
        }
    }
    
    /// Save a new goal button.
    private var saveButton: some View {
        Button {
            Task {
                await goalAddEditVM.save()
                dismiss()
            }
        } label: {
            Text("Save")
                .font(FontManager.Bungee.regular.font(size: 14))
                .foregroundStyle(goalAddEditVM.goalForm.isValid ? .sunglow : .sunglow.opacity(0.5))
        }
        .disabled(!goalAddEditVM.goalForm.isValid || goalAddEditVM.savingInProgress)
    }
    
    /// Edit goal button.
    private var updateButton: some View {
        Button {
            Task {
                await goalAddEditVM.update()
                dismiss()
            }
        } label: {
            Text("Update")
                .font(FontManager.Bungee.regular.font(size: 14))
                .foregroundStyle(goalAddEditVM.goalForm.isValid ? .sunglow : .sunglow.opacity(0.5))
        }
        .disabled(!goalAddEditVM.goalForm.isValid || goalAddEditVM.savingInProgress)
    }
    
    /// Delete goal button.
    private var deleteButton: some View {
        Button {
            showDeleteGoalPopover = true
        } label: {
            Text("Delete")
                .font(FontManager.Bungee.regular.font(size: 14))
                .foregroundStyle(goalAddEditVM.goalForm.isValid ? .utOrange : .utOrange.opacity(0.5))
        }
    }
    
    /// The forms section header.
    func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(FontManager.Bungee.regular.font(size: 24))
            .foregroundStyle(.textPrimary)
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
                        guard let goal = goal else { return }
                        await goalAddEditVM.delete(for: goal)
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.7))
    }
}

#Preview {
    NavigationStack {
        GoalAddEditView(
            goal: nil,
            goalAddEditVM: GoalAddEditViewModel(editGoal: nil, firebaseService: FirebaseService()))
            .environmentObject(GoalViewModel(firebaseService: FirebaseService())
        )
    }
}
