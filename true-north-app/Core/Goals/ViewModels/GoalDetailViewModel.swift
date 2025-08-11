import SwiftUI

class GoalDetailViewModel: ObservableObject {
    /// Goals service.
    private let service = GoalService()
    
    /// Save progress for a goal.
    ///
    /// - Parameter goalId: The goal id which the progress is being made on.
    ///
    func saveProgress(for goalId: String) async throws {
        try await service.saveProgress(for: goalId)
    }
    
    /// Delete the goal and the progress made on the goal.
    ///
    /// - Parameter goalId: The goal id which data the delete.
    ///
    func deleteGoalAndHistory(for goalId: String) async throws {
        try await service.deleteGoalAndHistory(for: goalId)
    }
    
    func checkUpdated(for goal: Goal, selectedDate: Date) async throws -> Bool {
        return try await service.checkIfUpdateMadeGoal(for: goal, selectedDate: selectedDate)
    }
}
