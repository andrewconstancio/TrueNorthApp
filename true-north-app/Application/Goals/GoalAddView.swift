import SwiftUI
import Firebase

struct GoalAddView: View {
    /// The goal view model.
    @StateObject var goalAddEditVM = GoalAddEditViewModel()
    
    /// The dismiss environment object.
    @Environment(\.dismiss) private var dismiss
    
    /// Flag if the description is focused.
    @FocusState private var isDescriptionFocused: Bool

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
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task {
                        await goalAddEditVM.save()
                        dismiss()
                    }
                } label: {
                    Text("Save")
                        .font(FontManager.Bungee.regular.font(size: 14))
                        .foregroundStyle(goalAddEditVM.newGoalForm.isValid ? .sunglow : .sunglow.opacity(0.5))
                }
                .disabled(!goalAddEditVM.newGoalForm.isValid || goalAddEditVM.savingInProgress)
            }
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
                    if goalAddEditVM.newGoalForm.name.isEmpty {
                        Text("What do you want to achieve?")
                            .font(FontManager.Bungee.regular.font(size: 16))
                            .foregroundStyle(.textPrimary.opacity(0.2))
                    }
                    
                    TextField("", text: $goalAddEditVM.newGoalForm.name)
                        .font(FontManager.Bungee.regular.font(size: 16))
                        .foregroundStyle(.textPrimary)
                        .frame(minHeight: 20)
                        .accessibilityLabel("Goal name")
                }
                
                Divider()
                
                descriptionEditor
            }
            .padding()
            .modifier(FormSection(tintColor: goalAddEditVM.newGoalForm.selectedColor))
        }
    }
    
    /// The goals desciption.
    var descriptionEditor: some View {
        ZStack(alignment: .topLeading) {
            if goalAddEditVM.newGoalForm.description.isEmpty && !isDescriptionFocused {
                Text("Add a detailed description of your goal...")
                    .font(FontManager.Bungee.regular.font(size: 16))
                    .foregroundStyle(.textPrimary.opacity(0.2))
                    .padding(.top, 8)
            }

            TextEditor(text: $goalAddEditVM.newGoalForm.description)
                .font(FontManager.Bungee.regular.font(size: 16))
                .foregroundStyle(.textPrimary)
                .focused($isDescriptionFocused)
                .scrollContentBackground(.hidden)
                .frame(minHeight: 80)
                .accessibilityLabel("Goal description")
        }
    }
    
    /// The goals target complete date.
    var goalTargetDateSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Timeline")
            
            VStack(spacing: 16) {
                if !goalAddEditVM.newGoalForm.isEndless {
                    HStack {
                        Text("Target Date")
                            .font(FontManager.Bungee.regular.font(size: 16))
                            .foregroundStyle(.textPrimary)
                        Spacer()
                        
                        HStack {
                            Text(goalAddEditVM.newGoalForm.endDate.formattedDateString)
                                .font(FontManager.Bungee.regular.font(size: 14))
                                .foregroundStyle(.textPrimary)

                            Image(systemName: "pencil")
                        }
                        .overlay {
                            DatePicker(
                                "",
                                selection: $goalAddEditVM.newGoalForm.endDate,
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
                    
                    Toggle("", isOn: $goalAddEditVM.newGoalForm.isEndless)
                        .labelsHidden()
                }
            }
            .padding()
            .modifier(FormSection(tintColor: goalAddEditVM.newGoalForm.selectedColor))
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
                    Picker(selection: $goalAddEditVM.newGoalForm.category) {
                        ForEach(GoalCategories.allCases, id: \.self) { category in
                            Text(category.rawValue.capitalized)
                                .tag(category.rawValue)
                        }
                    } label: {}
                } label: {
                    Text(goalAddEditVM.newGoalForm.category)
                        .font(FontManager.Bungee.regular.font(size: 14))
                        .foregroundStyle(.textPrimary)
                }
            }
            .padding()
            .modifier(FormSection(tintColor: goalAddEditVM.newGoalForm.selectedColor))
        }
    }
    
    /// The forms section header.
    func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(FontManager.Bungee.regular.font(size: 24))
            .foregroundStyle(.textPrimary)
    }
}

#Preview {
    NavigationStack {
        GoalAddView()
            .environmentObject(GoalViewModel())
    }
}
