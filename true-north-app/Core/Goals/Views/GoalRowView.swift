
import SwiftUI

struct GoalRowView: View {
    @State private var animateBorder = false
    let goal: Goal
    let goalIndex: Int
    let selectedDate: Date
    @ObservedObject var goalRowViewModel: GoalRowViewModel
    
    init(goal: Goal, goalIndex: Int, selectedDate: Date) {
        self.goal = goal
        self.goalIndex = goalIndex
        self.selectedDate = selectedDate
        self.goalRowViewModel = GoalRowViewModel(goal: goal, selectedDate: selectedDate)
    }
    
    var body: some View {
        ZStack {
            // Animated glowing border
            if !goalRowViewModel.didComplete {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.indigo.opacity(0.7), lineWidth: 3)
                    .scaleEffect(animateBorder ? 1 : 0.97)
                    .opacity(animateBorder ? 0.3 : 0.8)
                    .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: animateBorder)
    
            }

            // Your existing card content
            ZStack {
                NavigationLink(value: goalIndex) {
                    EmptyView()
                }
                .opacity(0)

                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(goal.title)
                                .font(.headline)
                                .foregroundStyle(goalRowViewModel.didComplete ? .primary : .tertiary)

                            Text(goal.description)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(goalRowViewModel.didComplete ? Color(hex: goal.color.hexToInt!).opacity(0.6) : Color(hex: goal.color.hexToInt!).opacity(0.4))
                )
                .padding(.horizontal, 4)
            }
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets())
        }
        .onAppear {
            animateBorder = true
        }
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
    }
}

#Preview {
    GoalRowView(
        goal: .dummy,
        goalIndex: 0,
        selectedDate: Date()
    )
}
