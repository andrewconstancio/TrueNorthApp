import SwiftUI

struct GoalsEditView: View {
    /// ViewModel for handling goal data
    @ObservedObject var goalViewModel: GoalViewModel

    /// The goals name text.
    @State private var goalName: String = ""
    
    /// The goals description text.
    @State private var goalDescription: String = ""
    
    /// The selected category of the goal.
    @State private var category: String = "Personal"
    
    /// The start date of the goal.
    @State private var startDate: Date = Date()
    
    /// If the goal does not have a end date.
    @State private var endlessGoal: Bool = false
    
    /// The end date of the goal.
    @State private var endDate: Date = Calendar.current.date(byAdding: .day, value: 30, to: Date())!
    
    /// The theme goal of the goal.
    @State private var selectedColor: Color = .blue
    
    /// The selected term of the goal.
    @State private var selectedTerm: GoalTerm = .medium

    /// Focus state for managing keyboard behavior
    @FocusState private var isDescriptionFocused: Bool
    
    /// Dismisses the view when called
    @Environment(\.dismiss) var dismiss

    /// Available categories
    let categories = ["Personal", "Health", "Career", "Fitness", "Education", "Finance"]

    /// An enumeration representing goal duration with associated colors.
    enum GoalTerm: String, CaseIterable {
        case short = "Short"
        case medium = "Medium"
        case long = "Long"
        
        var color: Color {
            switch self {
            case .short: return .yellow
            case .medium: return .green
            case .long: return .purple
            }
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                goalInputSection
                targetDate
                type
                Spacer(minLength: 50)
            }
            .padding()
        }
        .navigationTitle("Add Goal")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            toolbarSaveButton // Save button in top-right corner
        }
    }

    /// Section for goal title and description.
    private var goalInputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextField("Goal Name", text: $goalName)
                .textFieldStyle(.plain)
                .font(.headline)
                .accessibilityLabel("Goal name")
            
            Divider()
            
            descriptionEditor
        }
        .padding(2)
        .modifier(FormSection(tintColor: selectedColor))
    }

    /// Custom TextEditor with placeholder for description.
    private var descriptionEditor: some View {
        ZStack(alignment: .topLeading) {
            // Placeholder
            if goalDescription.isEmpty && !isDescriptionFocused {
                Text("Description")
                    .bold()
                    .foregroundColor(Color.primary.opacity(0.2))
                    .padding(.top, 7)
            }

            TextEditor(text: $goalDescription)
                .focused($isDescriptionFocused)
                .scrollContentBackground(.hidden)
                .frame(minHeight: 100)
                .accessibilityLabel("Goal description")
        }
    }

    /// Section to select the goal's target date.
    private var targetDate: some View {
        
        VStack(alignment: .trailing, spacing: 20) {
            HStack {
                Text("Target Date")
                    .fontWeight(.bold)
                Spacer()
                DatePicker("", selection: $endDate, displayedComponents: .date)
            }
            
            Button {
                endlessGoal.toggle()
            } label: {
                Text("Endless")
                    .fontWeight(.bold)
                    .padding(8)
                    .background(
                         RoundedRectangle(cornerRadius: 12)
                            .fill(Color.indigo.opacity(endlessGoal ? 0.9 : 0.2))
                     )
                     .overlay(
                          RoundedRectangle(cornerRadius: 12)
                             .stroke(Color.indigo, lineWidth: 1)
                     )
            }
        }
        .modifier(FormSection(tintColor: selectedColor))
    }

    /// Section to choose a goal category.
    private var type: some View {
        HStack {
            Text("Type")
                .fontWeight(.bold)
            Spacer()
            Picker("Category", selection: $category) {
                ForEach(categories, id: \.self) {
                    Text($0)
                        .foregroundStyle(.primary)
                }
            }
        }
        .modifier(FormSection(tintColor: selectedColor))
    }

    /// Section to select goal term (short, medium, long)
    private var termSelectionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("What's the term of this goal?")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 12) {
                ForEach(GoalTerm.allCases, id: \.self) { term in
                    termButton(for: term)
                }
            }
        }
        .modifier(FormSection(tintColor: selectedColor))
    }

    /// Section for color selection.
    private var colorSelction: some View {
        HStack {
            Text("Color")
                .fontWeight(.bold)
            Spacer()
            ColorPicker("", selection: $selectedColor)
        }
        .modifier(FormSection(tintColor: selectedColor))
    }

    /// Button used to select a term with animated visual feedback.
    private func termButton(for term: GoalTerm) -> some View {
        Button {
            selectedTerm = term
        } label: {
            Text(term.rawValue)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(selectedTerm == term ? .white : term.color)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(selectedTerm == term ? term.color : term.color.opacity(0.15))
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(term.color, lineWidth: selectedTerm == term ? 0 : 1)
                    }
                )
                .shadow(color: term.color.opacity(0.3), radius: selectedTerm == term ? 4 : 1, x: 0, y: 2)
                .scaleEffect(selectedTerm == term ? 1.03 : 1.0)
                .animation(.easeOut(duration: 0.2), value: selectedTerm == term)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(term.rawValue) term")
        .accessibilityHint("Select \(term.rawValue) term for this goal")
    }

    /// Save button in toolbar that triggers save logic and dismisses the view.
    private var toolbarSaveButton: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button("Save") {
                Task {
                    do {
                        try await goalViewModel.saveGoal(
                            title: goalName,
                            description: goalDescription,
                            term: selectedTerm.rawValue,
                            endDate: endDate,
                            category: category,
                            selectedColor: selectedColor
                        )
                        dismiss() // Close the view on successful save
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
            .fontWeight(.semibold)
            .disabled(goalName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
    }
}

#Preview {
    NavigationStack {
        GoalsEditView(goalViewModel: GoalViewModel())
    }
}
