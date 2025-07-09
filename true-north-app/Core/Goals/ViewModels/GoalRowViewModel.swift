//
//  GoalRowViewModel.swift
//  true-north-app
//
//  Created by Andrew Constancio on 7/9/25.
//

import SwiftUI


class GoalRowViewModel: ObservableObject {
    let goal: Goal
    let selectedDate: Date
    let service = GoalService()
    @Published var didComplete: Bool = false
    
    init(goal: Goal, selectedDate: Date) {
        self.goal = goal
        self.selectedDate = selectedDate
        Task {
            try? await checkIfUpdateMade()
        }
    }
    
    @MainActor
    func checkIfUpdateMade() async throws {
        do {
            self.didComplete = try await service.checkIfUpdateMadeGoal(for: goal, selectedDate: selectedDate)
        } catch {
            print(error.localizedDescription)
        }
    }
}
