import SwiftUI

class CalendarViewModel : ObservableObject {
    /// Firebase goal service.
    private var goalFirebaseService: GoalFirebaseService
    
    /// Array of days for the month, true or false if all the goals where completed for the day.
    @Published var completedDays = [Date: Bool]()
    
    /// App error.
    @Published var appError: AppError?
    
    /// Flag to show the app error.
    @Published var showAppError = false
    
    /// Initializer for this view model.
    /// - Parameter goalFirebaseService: Firebase goal service.
    init(goalFirebaseService: GoalFirebaseService = .init()) {
        self.goalFirebaseService = goalFirebaseService
    }
    
    /// Fetches and array the represent the days of the month and where the goals were completed.
    /// - Parameter month: The month to fetch.
    func fetchDaysCompleted(for month: DateComponents) async {
        do {
            let completed = try await goalFirebaseService.fetchCompletedDaysFor(monthComponents: month)
            
            await MainActor.run {
                self.completedDays = completed
            }
        } catch {
            print(error.localizedDescription)
            appError = AppError.customError(message: "Failed to fetch completed days.")
            showAppError = true
        }
    }
}
