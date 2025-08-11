import SwiftUI


enum GoalCompletionState {
    case notStarted
    case inProgress
    case completed
}

@MainActor
class GoalRowViewModel: ObservableObject {
    let goal: Goal
    let selectedDate: Date
    let isPastDate: Bool
    private let service: GoalService
    
    @Published var goalCompletedState: GoalCompletionState = .inProgress
    @Published var isLoading: Bool = false
    
    init(goal: Goal, selectedDate: Date, isPastDate: Bool, service: GoalService = GoalService()) {
        self.goal = goal
        self.selectedDate = selectedDate
        self.isPastDate = isPastDate
        self.service = service
        
        Task {
            await loadCompletionState()
        }
    }
    
    func loadCompletionState() async {
        isLoading = true
        
        do {
            let completed = try await service.checkIfUpdateMadeGoal(for: goal, selectedDate: selectedDate)
            
            if completed {
                goalCompletedState = .completed
            } else if isPastDate {
                goalCompletedState = .notStarted
            }
        } catch {
            print("Failed to load completion state: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
}
