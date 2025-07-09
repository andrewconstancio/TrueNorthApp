//
//  GoalsEditView.swift
//  true-north-app
//
//  Created by Andrew Constancio on 7/7/25.
//

import SwiftUI

struct GoalsEditView: View {
    @ObservedObject var goalViewModel: GoalViewModel
    @State private var goalName: String = ""
    @State private var goalDescription: String = ""
    @State private var selectedTerm: GoalTerm = .short
    @FocusState private var isDescriptionFocused: Bool
    @Environment(\.dismiss) var dismiss
    
    // MARK: - Goal Term Enum
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
                termSelectionSection
                Spacer(minLength: 50)
            }
            .padding()
        }
        .navigationTitle("Edit Goal")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    // Save the goal
                    Task {
                        do {
                            try await goalViewModel.saveGoal(
                                title: goalName,
                                description: goalDescription,
                                term: selectedTerm.rawValue
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
    
    // MARK: - Goal Input Section
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
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
    
    private var descriptionEditor: some View {
        ZStack(alignment: .topLeading) {
            if goalDescription.isEmpty && !isDescriptionFocused {
//                Text("Description")
                Text("Description")
                    .fontWeight(.bold)
                    .foregroundColor(Color.primary.opacity(0.25))
                    .padding(EdgeInsets(top: 7, leading: 4, bottom: 0, trailing: 0))
//                    .fontWeight(.bold)
//                    .foregroundColor(.black.opacity(0.2))
//                    .padding(.top, 8)
//                    .allowsHitTesting(false)
            }
            
            TextEditor(text: $goalDescription)
                .focused($isDescriptionFocused)
                .scrollContentBackground(.hidden)
                .frame(minHeight: 100)
                .accessibilityLabel("Goal description")
        }
    }
    
    // MARK: - Term Selection Section
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
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
    
    private func termButton(for term: GoalTerm) -> some View {
        Button {
            selectedTerm = term
        } label: {
            Text(term.rawValue)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(selectedTerm == term ? term.color : term.color.opacity(0.2))
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(term.rawValue) term")
        .accessibilityHint("Select \(term.rawValue) term for this goal")
    }
}

#Preview {
    NavigationStack {
        GoalsEditView(goalViewModel: GoalViewModel())
    }
}
