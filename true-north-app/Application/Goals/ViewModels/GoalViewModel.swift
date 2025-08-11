import SwiftUI
import Firebase
import FirebaseAuth

class GoalViewModel: ObservableObject {
    /// The selected date. 
    @Published var selectedDate: Date = Date()
    
    /// Optional app error.
    @Published var appError: AppError?
    
    /// Show the app error.
    @Published var showAppError = false
    
    /// The new goal form.
    @Published var newGoalForm = GoalFormData()
    
    /// Flag if currently saving a goal.
    @Published var savingInProgress = false
    
    /// An array of the users goals. 
    @Published var goals: [Goal] = []
    
    /// Goals service.
    private let service = GoalFirebaseService()
    
    /// Fetch the goals of the user for a specfic date.
    func fetchGoals() async {
        do {
            let goals = try await service.fetchGoals(selectedDate: selectedDate)
            
            await MainActor.run {
                self.goals = goals
            }
            
        } catch {
            appError = AppError.customError(message: "Something went wrong when fetching your goals! Try again later.")
            print(error.localizedDescription)
        }
    }
    
    /// Handles sending the phone number for auth.
    ///
    /// - Parameter Goal: A new goal created by the user.
    ///
    func save() async {
        do {
            guard newGoalForm.isValid else { return }
            let goal = Goal(
                title: newGoalForm.name.trimmingCharacters(in: .whitespacesAndNewlines),
                description: newGoalForm.description.trimmingCharacters(in: .whitespacesAndNewlines),
                dateCreated: Timestamp(),
                complete: false,
                category: newGoalForm.category,
                uid: "",
                streak: 0,
                endDate: newGoalForm.isEndless ? nil : newGoalForm.endDate
            )
            
            await MainActor.run {
                savingInProgress = true
            }
            
            try await service.saveGoal(goal)
        } catch {
            savingInProgress = false
            print(error.localizedDescription)
        }
    }
}
