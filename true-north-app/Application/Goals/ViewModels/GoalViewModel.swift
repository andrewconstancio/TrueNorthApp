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
}
