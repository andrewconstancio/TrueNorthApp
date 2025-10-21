import SwiftUI
import Firebase
import FirebaseAuth

/// Possible status of the each daily goal entry.
enum GoalCompletionState {
    case notStarted
    case inProgress
    case completed
}

class GoalViewModel: ObservableObject {
    /// The selected date. 
    @Published var selectedDate: Date = Date()
    
    /// Optional app error.
    @Published var appError: AppError?
    
    /// Show the app error.
    @Published var showAppError = false
    
    /// An array of the users goals. 
    @Published var goals: [Goal] = []
    
    @Published var isLoading = false
    
    /// Firebase service.
    let firebaseService: FirebaseServiceProtocol
    
    init(firebaseService: FirebaseServiceProtocol) {
        self.firebaseService = firebaseService
    }
    
    /// Fetch the goals of the user for a specfic date.
    @MainActor
    func fetchGoals() async {
        do {
            isLoading = true
            let goals = try await firebaseService.fetchGoals(selectedDate: selectedDate)
            
            await MainActor.run {
                self.goals = goals
            }
            isLoading = false
        } catch {
            appError = AppError.customError(message: "Something went wrong when fetching your goals! Try again later.")
            print(error.localizedDescription)
        }
    }
    
    /// Check if all the goals were completed for the day.
    /// - Parameter selectedDate: The day to check.
    /// - Returns: `True` or `False` if all the goals were completed for the day.
    func checkCompletedForDay(_ selectedDate: Date) async -> Bool {
        do {
            let completed = try await firebaseService.checkCompletedForDay(selectedDate: selectedDate)
            return completed
        } catch {
            return false
        }
    }
    
    /// Checks to see if a daily update entry was made for specific goal.
    /// - Parameters:
    ///   - goalId: The goal id.
    ///   - selectedDate: The day to check.
    /// - Returns: `GoalCompletionState`
    @MainActor
    func checkDailyEntry(for goalId: String, selectedDate: Date) async -> GoalCompletionState {
        do {
            
            let isCompleted = try await firebaseService.checkDailyEntry(
                for: goalId,
                selectedDate: selectedDate
            )
            
            if isCompleted {
                return .completed
            } else if selectedDate.isDateInPast() {
                return .notStarted
            }
            
            return .inProgress
        } catch {
            print("Failed to load completion state: \(error.localizedDescription)")
            return .notStarted
        }
    }
}
