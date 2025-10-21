import SwiftUI

class GoalDetailViewModel: ObservableObject {
    
    /// The daily entry goal title input.
    @Published var goalReEntryText = ""
    
    @Published var showSaveButton = false
    
    @Published var dailyEntryCompleted = false
    
    @Published var appError: AppError?
    
    @Published var showAppError = false
    
    @Published var goal: Goal
    
    /// Firebase service.
    let firebaseService: FirebaseServiceProtocol
    
    init(goal: Goal, firebaseService: FirebaseServiceProtocol) {
        self.goal = goal
        self.firebaseService = firebaseService
    }
    
    /// Save progress for a goal.
    ///
    /// - Parameter goalId: The goal id which the progress is being made on.
    ///
    func saveProgress(for goalId: String) async {
        do {
            try await firebaseService.saveProgress(for: goalId)
            let increment = try await firebaseService.entryAddedYesterday(for: goalId)
            try await firebaseService.setGoalStreak(for: goalId, increment: increment)
            try await firebaseService.updateCompletedForDay()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    /// Check if goals progress was updated for a selected date.
    /// - Parameters:
    ///   - goal: The users goals
    ///   - selectedDate: The selected date.
    /// - Returns: True if goals progress was updated on the date..
    func checkUpdated(for goal: Goal, selectedDate: Date) async {
        do {
            guard let id = goal.id else { return }
            let completed = try await firebaseService.checkDailyEntry(
                for: id,
                selectedDate: selectedDate
            )
            
            await MainActor.run {
                self.dailyEntryCompleted = completed
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
    /// Fetches the goal data from firestore.
    /// - Parameter goalId: The goal id to fetch.
    @MainActor
    func refreshGoal(_ goalId: String) async -> Bool {
        do {
            let goal = try await firebaseService.fetchGoal(by: goalId)
            self.goal = goal
            
            goalReEntryText = ""
            
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    
    /// Handles checking if each character entered in the goal re-entry text is equal to the
    /// goals target text.
    func handleGoalTextChange() {
        let targetText = goal.title.lowercased()
        let reEntryText = goalReEntryText.lowercased()
        
        var validInput = ""
        var goalIndex = 0
        
        // Check to see if the entered text is equal to the goals title.
        for char in reEntryText {
            guard goalIndex < targetText.count else { break }
            
            let titleIndexChar = targetText.index(targetText.startIndex, offsetBy: goalIndex)
            let goalChar = targetText[titleIndexChar]
            
            if char == goalChar || char == " " {
                validInput.append(goalChar)
                goalIndex += 1
            } else {
                break
            }
        }
        
        // Only assign the re-entry text to valid input.
        goalReEntryText = validInput
        
        // If the re-entry text is equal to teh target text show save button.
        if targetText == goalReEntryText.lowercased() {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                self.showSaveButton = true
            }
        }
    }
}
