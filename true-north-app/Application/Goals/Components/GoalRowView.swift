import SwiftUI

struct GoalRowView: View {
    /// The users goal.
    let goal: Goal
    
    /// The selected date for the goal.
    @Binding var selectedDate: Date
    
    /// Goal row view model for this view.
    @StateObject var vm = GoalRowViewModel()
    
    /// Flag to animate the row border.
    @State private var animateBorder = false
    
    var body: some View {
        ZStack {
            if vm.goalCompletedState == .inProgress && !selectedDate.isDateInPast() {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.lime.opacity(0.7), lineWidth: 3)
                    .scaleEffect(animateBorder ? 1 : 0.97)
                    .opacity(animateBorder ? 0.3 : 0.8)
                    .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: animateBorder)
            }
            
            ZStack {
                goalContent(
                    title: goal.title,
                    description: goal.description,
                    steak: goal.streak,
                    endDate: goal.endDate,
                    icon: GoalCategories(rawValue: goal.category.lowercased())?.icon ?? "question-mark",
                    color: GoalCategories(rawValue: goal.category.lowercased())?.color ?? Color.disabled,
                    state: vm.goalCompletedState
                )
            }
        }
        .onAppear {
            Task {
                guard let id = goal.id else { return }
                await vm.checkDailyEntry(
                    for: id,
                    selectedDate: selectedDate
                )
            }
        }
    }
    
    /// Builds the goal row content based on the state
    @ViewBuilder
    private func goalContent(
        title: String,
        description: String,
        steak: Int,
        endDate: Date?,
        icon: String,
        color: Color,
        state: GoalCompletionState
    ) -> some View {
        let styles = stylesForState(state, color)
        
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
                    
                    if let endDate = endDate {
                        HStack(spacing: 8) {
                            Image(systemName: "target")
                                .frame(width: 14, height: 14)
                                .foregroundStyle(styles.descriptionColor)
                            
                            Text("\(endDate.formattedDateString)")
                                .font(FontManager.Bungee.regular.font(size: 14))
                                .foregroundStyle(styles.descriptionColor)
                        }
                    }
                }
                
                Spacer()
                
                if steak > 0 {
                    Text("\(steak)")
                        .font(FontManager.Bungee.regular.font(size: 18))
                        .foregroundStyle(styles.titleColor)
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
    private func stylesForState(_ state: GoalCompletionState,_ color: Color) -> (iconOpacity: Double, titleColor: Color, descriptionColor: Color, background: Color) {
        switch state {
        case .completed:
            return (1.0, Color.textPrimary, .textSecondary, color)
        case .inProgress:
            return (1.0, Color.textPrimary.opacity(0.4), Color.textSecondary.opacity(0.4), color.opacity(0.4))
        case .notStarted:
            return (1.0, Color.textPrimary.opacity(0.4), Color.textSecondary.opacity(0.4), .disabled)
        }
    }
}


//#Preview {
//    GoalRowView(
//        goal: .dummy,
//        selectedDate: Binding(Date())
//    )
//}
