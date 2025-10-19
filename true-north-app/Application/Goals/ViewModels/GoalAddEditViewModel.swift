import FirebaseFirestore

class GoalAddEditViewModel: ObservableObject {
    
    /// The new goal form.
    @Published var newGoalForm = GoalFormData()
    
    /// Flag if currently saving a goal.
    @Published var savingInProgress = false
    
    /// Goals service.
    private let service = GoalFirebaseService()
    
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
