import SwiftUI

struct FormSection: ViewModifier {
    var tintColor: Color
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(
              ZStack {
                  RoundedRectangle(cornerRadius: 12, style: .continuous)
                      .fill(.ultraThinMaterial)
                  RoundedRectangle(cornerRadius: 12, style: .continuous)
                      .fill(tintColor.opacity(0.2))
              }
            )
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

struct GoalsEditView: View {
    @ObservedObject var goalViewModel: GoalViewModel
    
    @State private var goalName: String = ""
    @State private var goalDescription: String = ""
    @State private var selectedTerm: GoalTerm = .short
    @State private var category: String = "Personal"
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Calendar.current.date(byAdding: .day, value: 30, to: Date())!
    @State private var emoji: String = "🎯"
    @State private var selectedColor: Color = .blue
    
    @FocusState private var isDescriptionFocused: Bool
    @Environment(\.dismiss) var dismiss
    
    let categories = ["Personal", "Health", "Career", "Fitness", "Education", "Finance"]
    
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
                termSelectionSection
                colorSelction
                Spacer(minLength: 50)
            }
            .padding()
        }
        .navigationTitle("Edit Goal")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            toolbarSaveButton
        }
    }
    
    private var goalInputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextField("Goal Name", text: $goalName)
                .textFieldStyle(.plain)
                .font(.headline)
                .accessibilityLabel("Goal name")
            
            Divider()
            
            descriptionEditor
        }
        .padding(16)
        .modifier(FormSection(tintColor: selectedColor))
    }
    
    private var descriptionEditor: some View {
        ZStack(alignment: .topLeading) {
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
    
    private var targetDate: some View {
        HStack {
            Text("Target Date")
                .fontWeight(.bold)
            Spacer()
            DatePicker("", selection: $endDate, displayedComponents: .date)
        }
        .modifier(FormSection(tintColor: selectedColor))
    }
    
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
    
    private var colorSelction: some View {
        HStack {
            Text("Color")
                .fontWeight(.bold)
            
            Spacer()
            ColorPicker("", selection: $selectedColor)
        }
        .modifier(FormSection(tintColor: selectedColor))
    }
    
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
    
    private var toolbarSaveButton: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button("Save") {
                // Save the goal
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
                        
                        // Dismiss the view
                        dismiss()
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
