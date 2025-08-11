import SwiftUI
import Firebase
import FirebaseAuth

class GoalViewModel: ObservableObject {
    /// A array of the users goals
    @Published var goals: [Goal] = []
    
    /// The selected date. 
    @Published var selectedDate: Date = Date()
    
    /// Goals service.
    private let service = GoalService()
    
    /// Fetch the goals of the user for a specfic date.
    func fetchGoals() async throws {
        let goals = try await service.fetchGoals(for: selectedDate)
        
        await MainActor.run {
            self.goals = goals
        }
    }
    
    /// Handles sending the phone number for auth.
    ///
    /// - Parameter Goal: A new goal created by the user.
    ///
    func saveGoal(_ goal: Goal) async throws {
        try await service.saveGoal(goal)
    }
}
