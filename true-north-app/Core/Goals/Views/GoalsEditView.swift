import SwiftUI
import Firebase

struct GoalsEditView: View {
    @ObservedObject var goalViewModel: GoalViewModel
    @State private var formData = GoalFormData()
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var isSaving = false
    
    @FocusState private var isDescriptionFocused: Bool
    @Environment(\.dismiss) private var dismiss

    var body: some View {
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
        .toolbar { toolbarContent }
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .background(.backgroundPrimary)
    }
    
    var goalBasicInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Goal Details")
            
            VStack(alignment: .leading, spacing: 12) {
                ZStack(alignment: .topLeading) {
                    if formData.name.isEmpty {
                        Text("What do you want to achieve?")
                            .font(FontManager.Bungee.regular.font(size: 16))
                            .foregroundStyle(.textPrimary.opacity(0.2))
                    }
                    
                    TextField("", text: $formData.name)
                        .font(FontManager.Bungee.regular.font(size: 16))
                        .foregroundStyle(.textPrimary)
                        .frame(minHeight: 20)
                        .accessibilityLabel("Goal name")
                }
                
                Divider()
                
                descriptionEditor
            }
            .padding()
            .modifier(FormSection(tintColor: formData.selectedColor))
        }
    }
    
    var descriptionEditor: some View {
        ZStack(alignment: .topLeading) {
            if formData.description.isEmpty && !isDescriptionFocused {
                Text("Add a detailed description of your goal...")
                    .font(FontManager.Bungee.regular.font(size: 16))
                    .foregroundStyle(.textPrimary.opacity(0.2))
                    .padding(.top, 8)
            }

            TextEditor(text: $formData.description)
                .font(FontManager.Bungee.regular.font(size: 16))
                .foregroundStyle(.textPrimary)
                .focused($isDescriptionFocused)
                .scrollContentBackground(.hidden)
                .frame(minHeight: 80)
                .accessibilityLabel("Goal description")
        }
    }
    
    var goalTargetDateSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Timeline")
            
            VStack(spacing: 16) {
                if !formData.isEndless {
                    HStack {
                        Text("Target Date")
                            .font(FontManager.Bungee.regular.font(size: 16))
                            .foregroundStyle(.textPrimary)
                        Spacer()
                        
                        HStack {
                            Text(formData.endDate.formattedDateString)
                                .font(FontManager.Bungee.regular.font(size: 14))
                                .foregroundStyle(.textPrimary)

                            Image(systemName: "pencil")
                        }
                        .overlay {
                            DatePicker(
                                "",
                                selection: $formData.endDate,
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
                    
                    Toggle("", isOn: $formData.isEndless)
                        .labelsHidden()
                }
            }
            .padding()
            .modifier(FormSection(tintColor: formData.selectedColor))
        }
    }
    
    var goalCategorySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Category")
            
            HStack {
                Text("Type")
                    .font(FontManager.Bungee.regular.font(size: 16))
                    .foregroundStyle(.textPrimary)
                
                Spacer()
                
                Menu {
                    Picker(selection: $formData.category) {
                        ForEach(GoalCategories.allCases, id: \.self) { category in
                            Text(category.rawValue)
                                .tag(category)
                        }
                    } label: {}
                } label: {
                    Text(formData.category)
                        .font(FontManager.Bungee.regular.font(size: 14))
                        .foregroundStyle(.textPrimary)
                }
            }
            .padding()
            .modifier(FormSection(tintColor: formData.selectedColor))
        }
    }
    
    func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(FontManager.Bungee.regular.font(size: 24))
            .foregroundStyle(.textPrimary)
    }
    
    var toolbarContent: some ToolbarContent {
        Group {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    guard formData.isValid else { return }
                    let goal = Goal(
                        title: formData.name.trimmingCharacters(in: .whitespacesAndNewlines),
                        description: formData.description.trimmingCharacters(in: .whitespacesAndNewlines),
                        dateCreated: Timestamp(),
                        complete: false,
                        category: formData.category,
                        uid: "",
                        streak: 0
                    )
                    Task {
                        try? await goalViewModel.saveGoal(goal)
                        dismiss()
                    }
                } label: {
                    if isSaving {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Text("Save")
                            .font(FontManager.Bungee.regular.font(size: 14))
                            .foregroundStyle(formData.isValid ? .sunglow : .sunglow.opacity(0.5))
                    }
                }
                .disabled(!formData.isValid || isSaving)
            }
        }
    }
}

#Preview {
    NavigationStack {
        GoalsEditView(goalViewModel: GoalViewModel())
    }
}
