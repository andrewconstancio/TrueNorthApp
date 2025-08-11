import SwiftUI

struct GoalRowView: View {
    let goal: Goal
    let selectedDate: Date
    let isPastDate: Bool
    
    @ObservedObject var goalRowViewModel: GoalRowViewModel
    @State private var animateBorder = false
    
    init(goal: Goal, selectedDate: Date, isPastDate: Bool) {
        self.goal = goal
        self.selectedDate = selectedDate
        self.isPastDate = isPastDate
        self.goalRowViewModel = GoalRowViewModel(goal: goal, selectedDate: selectedDate, isPastDate: isPastDate)
    }
    
    var body: some View {
        ZStack {
            if goalRowViewModel.goalCompletedState == .inProgress && !isPastDate {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.lime.opacity(0.7), lineWidth: 3)
                    .scaleEffect(animateBorder ? 1 : 0.97)
                    .opacity(animateBorder ? 0.3 : 0.8)
                    .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: animateBorder)
            }
            
            ZStack {
                /// If its not the current day do not allow click into.
                if !isPastDate {
                    NavigationLink(value: goal) { EmptyView() }
                        .opacity(0)
                }
                
                goalContent(
                    title: goal.title,
                    description: goal.description,
                    icon: GoalCategories(rawValue: goal.category.lowercased())?.icon ?? "question-mark",
                    state: goalRowViewModel.goalCompletedState
                )
            }
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets())
        }
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
        .listRowBackground(Color.backgroundPrimary)
    }
    
    /// Builds the goal row content based on the state
    @ViewBuilder
    private func goalContent(title: String, description: String, icon: String, state: GoalCompletionState) -> some View {
        let styles = stylesForState(state)
        
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 20)
                    .padding(8)
                    .overlay(
                        Circle()
                            .stroke(Color.gray.opacity(0.3), lineWidth: 3)
                    )
                    .opacity(styles.iconOpacity)
                
                VStack(alignment: .leading) {
                    Text(title)
                        .font(FontManager.Bungee.regular.font(size: 22))
                        .foregroundStyle(styles.titleColor)
                    
                    Text(description)
                        .font(FontManager.Bungee.regular.font(size: 14))
                        .foregroundStyle(styles.descriptionColor)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(styles.background)
        )
        .padding(.horizontal, 4)
    }
    
    /// Style mapping per goal state
    private func stylesForState(_ state: GoalCompletionState) -> (iconOpacity: Double, titleColor: Color, descriptionColor: Color, background: Color) {
        switch state {
        case .completed:
            return (1.0, Color.textPrimary, .textSecondary, .spaceCadet)
        case .inProgress:
            return (1.0, Color.textPrimary.opacity(0.4), Color.textSecondary.opacity(0.4), .spaceCadet.opacity(0.4))
        case .notStarted:
            return (1.0, Color.textPrimary.opacity(0.4), Color.textSecondary.opacity(0.4), .disabled)
        }
    }
}


#Preview {
    GoalRowView(
        goal: .dummy,
        selectedDate: Date(),
        isPastDate: false
    )
}
