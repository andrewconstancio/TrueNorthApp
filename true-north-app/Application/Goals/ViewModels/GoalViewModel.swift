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
    
    /// Firebase service.
    let firebaseService: FirebaseServiceProtocol
    
    init(firebaseService: FirebaseServiceProtocol) {
        self.firebaseService = firebaseService
    }
    
    /// Fetch the goals of the user for a specfic date.
    func fetchGoals() async {
        do {
            let goals = try await firebaseService.fetchGoals(selectedDate: selectedDate)
            
            await MainActor.run {
                self.goals = goals
            }
            
        } catch {
            appError = AppError.customError(message: "Something went wrong when fetching your goals! Try again later.")
            print(error.localizedDescription)
        }
    }
    
    func checkCompletedForDay(_ selectedDate: Date) async -> Bool {
        do {
            let completed = try await firebaseService.checkCompletedForDay(selectedDate: selectedDate)
            return completed
        } catch {
            return false
        }
    }
}
