import SwiftUI

class GoalDetailViewModel: ObservableObject {
    
    /// The daily entry goal title input.
    @Published var goalTitleInputText = ""
    @Published var savingState = false
    @Published var dailyEntryCompleted = false
    @Published var appError: AppError?
    @Published var showAppError = false
    
    /// Goals firebase service.
    private let service = GoalFirebaseService()
    
    /// Save progress for a goal.
    ///
    /// - Parameter goalId: The goal id which the progress is being made on.
    ///
    func saveProgress(for goalId: String) async {
        do {
            try await service.saveProgress(for: goalId)
            let increment = try await service.entryAddedYesterday(for: goalId)
            try await service.setGoalStreak(for: goalId, increment: increment)
            
            
            try await service.updateCompletedForDay()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    /// Delete the goal and the progress made on the goal.
    ///
    /// - Parameter goalId: The goal id which data the delete.
    ///
    func deleteGoalAndHistory(for goal: Goal) async {
        do {
            try await service.deleteGoalAndHistory(for: goal)
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
            let completed = try await service.checkDailyEntry(
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
    
    func handleGoalTextChange(_ title: String) {
        let titleGoal = title.lowercased()
        let input = goalTitleInputText.lowercased()
        
        var validInput = ""
        var goalIndex = 0
        
        for char in input {
            guard goalIndex < titleGoal.count else { break }
            
            let goalChar = titleGoal[titleGoal.index(titleGoal.startIndex, offsetBy: goalIndex)]
            
            if char == goalChar || char == " " {
                validInput.append(title[title.index(title.startIndex, offsetBy: goalIndex)])
                goalIndex += 1
            } else {
                break
            }
        }
        
        goalTitleInputText = validInput
        
        if titleGoal == goalTitleInputText.lowercased() {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                self.savingState = true
            }
        }
    }
}
