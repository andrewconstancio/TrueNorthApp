import SwiftUI

/// Possible status of the each daily goal entry.
enum GoalCompletionState {
    case notStarted
    case inProgress
    case completed
}

class GoalRowViewModel: ObservableObject {
    /// The staus of the completed state of the goal for the day.
    @Published var goalCompletedState: GoalCompletionState = .inProgress

    /// The goal Firebase Firestore service.
    private let firebaseService: FirebaseServiceProtocol
    
    /// Initialize this view model.
    /// - Parameter goalService: The goal Firebase Firestore service.
    init(firebaseService: FirebaseServiceProtocol) {
        self.firebaseService = firebaseService
    }
    
    /// Checks if daily entry made for the goal.
    /// - Parameters:
    ///   - goalId: The goal id to check.
    ///   - selectedDate: The date to check.
    @MainActor
    func checkDailyEntry(for goalId: String, selectedDate: Date) async {
        do {
            goalCompletedState = .inProgress
            
            let isCompleted = try await firebaseService.checkDailyEntry(
                for: goalId,
                selectedDate: selectedDate
            )
            
            goalCompletedState = isCompleted
                    ? .completed
                    : (selectedDate.isDateInPast() ? .notStarted : goalCompletedState)
        } catch {
            print("Failed to load completion state: \(error.localizedDescription)")
        }
    }
}
