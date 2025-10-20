import FirebaseFirestore

class GoalAddEditViewModel: ObservableObject {
    
    /// The new goal form.
    @Published var goalForm = GoalFormData()
    
    /// Flag if currently saving a goal.
    @Published var savingInProgress = false
    
    /// The goal to be updates.
    private var editGoal: Goal?
    
    /// Firebase service.
    let firebaseService: FirebaseServiceProtocol
    
    init(editGoal: Goal?, firebaseService: FirebaseServiceProtocol) {
        self.firebaseService = firebaseService
        self.editGoal = editGoal
        
        if editGoal != nil {
            setupEdit()
        }
    }
    
    /// Assign the goal forms values to the goal that was passed in.
    func setupEdit() {
        goalForm.name = editGoal?.title ?? ""
        goalForm.description = editGoal?.description ?? ""
        goalForm.category = editGoal?.category ?? ""
        goalForm.endDate = editGoal?.endDate ?? Date()
        goalForm.isEndless = editGoal?.endDate == nil
    }
    
    /// Handles saving a goal.
    func save() async {
        do {
            guard goalForm.isValid else { return }
            let goal = Goal(
                title: goalForm.name.trimmingCharacters(in: .whitespacesAndNewlines),
                description: goalForm.description.trimmingCharacters(in: .whitespacesAndNewlines),
                dateCreated: Timestamp(),
                complete: false,
                category: goalForm.category,
                uid: "",
                streak: 0,
                endDate: goalForm.isEndless ? nil : goalForm.endDate
            )
            
            await MainActor.run {
                savingInProgress = true
            }
            
            try await firebaseService.saveGoal(goal)
        } catch {
            savingInProgress = false
            print(error.localizedDescription)
        }
    }
    
    
    /// Handles updating a goal.
    func update() async {
        do {
            guard goalForm.isValid else { return }
            let goal = Goal(
                id: editGoal?.id ?? "",
                title: goalForm.name.trimmingCharacters(in: .whitespacesAndNewlines),
                description: goalForm.description.trimmingCharacters(in: .whitespacesAndNewlines),
                dateCreated: editGoal?.dateCreated ?? Timestamp(),
                complete: false,
                category: goalForm.category,
                uid: editGoal?.uid ?? "",
                streak: editGoal?.streak ?? 0,
                endDate: goalForm.isEndless ? nil : goalForm.endDate
            )
            
            try await firebaseService.updateGoal(goal)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    /// Delete the goal and the progress made on the goal.
    ///
    /// - Parameter goalId: The goal id which data the delete.
    ///
    func delete(for goal: Goal) async {
        do {
            try await firebaseService.deleteGoalAndHistory(for: goal)
        } catch {
            print(error.localizedDescription)
        }
    }
}
