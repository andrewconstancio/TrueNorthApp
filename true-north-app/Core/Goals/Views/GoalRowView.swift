
//  GoalRowView.swift
//  true-north-app
//
//  Created by Andrew Constancio on 7/8/25.
//

import SwiftUI

struct GoalRowView: View {
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
            NavigationLink(value: goalIndex) {
                EmptyView()
            }
            .opacity(0)
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: "mappin")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                        .foregroundColor(.black)
                        .padding(8)
                        .background(Color(.systemYellow))
                        .frame(width: 32, height: 32)
                        .clipShape(Circle())
                    
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
            .padding(.vertical, 4)
        }
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets())
    }
}

//#Preview {
//    GoalRowView(
//        goal: Goal(title: "Test Goal" as? , description: "This is a test goal.")
//    )
//}
