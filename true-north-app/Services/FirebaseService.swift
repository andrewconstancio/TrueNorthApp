import FirebaseFirestore
import FirebaseAuth

protocol FirebaseServiceProtocol {
    func fetchUser(withUid uid: String, completion: @escaping(User) -> Void)
    func fetchUsers(completion: @escaping([User]) -> Void)
    func fetchGoals(selectedDate: Date) async throws -> [Goal]
    func fetchGoal(by goalId: String) async throws -> Goal
    func saveGoal(_ goal: Goal) async throws
    func updateGoal(_ goal: Goal) async throws
    func saveProgress(for goalId: String) async throws
    func updateCompletedForDay() async throws
    func checkCompletedForDay(selectedDate: Date) async throws -> Bool
    func fetchCompletedDaysFor(monthComponents: DateComponents) async throws -> [Date: Bool]
    func entryAddedYesterday(for goalId: String) async throws -> Bool
    func setGoalStreak(for goalId: String, increment: Bool) async throws
    func checkDailyEntry(for goalId: String, selectedDate: Date) async throws -> Bool
    func deleteGoalAndHistory(for goal: Goal) async throws
}

class FirebaseService: ObservableObject, FirebaseServiceProtocol {
    // MARK: User
    func fetchUser(withUid uid: String, completion: @escaping(User) -> Void) {
        Firestore.firestore().collection("users")
            .document(uid)
            .getDocument { snapshot, _ in
                guard let snapshot = snapshot else { return }
                var user: User
                
                do {
                    user = try snapshot.data(as: User.self)
                } catch {
                    print ("Error fetchUser: \(error)")
                    return
                }
                
                completion(user)
            }
    }
    
    func fetchUsers(completion: @escaping([User]) -> Void) {
        Firestore.firestore().collection("users")
            .getDocuments { snapshot, _ in
                guard let documents = snapshot?.documents else { return }
                let users = documents.compactMap({ try? $0.data(as: User.self)})
                
                completion(users)
            }
    }
    
    // MARK: Goals
    
    /// Fetched the goals for a specfic date.
    /// - Parameter selectedDate: The date to select goals from.
    /// - Returns: The goals for the user for the date.
    func fetchGoals(selectedDate: Date) async throws -> [Goal] {
        guard let uid = Auth.auth().currentUser?.uid else { return [] }

        let calendar = Calendar.current
        guard let startOfNextDay = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: selectedDate)) else {
            fatalError("Could not get next date.")
        }

        let snapshot = try await Firestore.firestore()
            .collection("goals")
            .whereField("uid", isEqualTo: uid)
            .whereField("dateCreated", isLessThan: Timestamp(date: startOfNextDay))
            .order(by: "dateCreated", descending: true)
            .getDocuments()

        let goals = try snapshot.documents.compactMap { doc in
            try doc.data(as: Goal.self)
        }
        
        return goals
    }
    
    /// Fetches a single goal by its ID.
    /// - Parameter goalId: The ID of the goal to fetch.
    /// - Returns: The goal with the matching ID.
    func fetchGoal(by goalId: String) async throws -> Goal {
        let document = try await Firestore.firestore()
            .collection("goals")
            .document(goalId)
            .getDocument()
        
        guard let goal = try? document.data(as: Goal.self) else {
            throw NSError(domain: "GoalFirebaseService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Goal not found"])
        }
        
        return goal
    }
    
    /// Saves a new goals for the user.
    /// - Parameter goal: The new user goal.
    func saveGoal(_ goal: Goal) async throws {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        var goal = goal
        goal.setUID(uid)
        
        try Firestore.firestore().collection("goals").addDocument(from: goal)
    }
    
    
    /// Update a users goal
    /// - Parameter goal: The goals updates object.
    func updateGoal(_ goal: Goal) async throws {
        guard let id = goal.id else { return }
        try Firestore.firestore().collection("goals").document(id).setData(from: goal)
    }

    /// Saves progress for a goal.
    /// - Parameter goalId: The goal id for the progress being made on.
    func saveProgress(for goalId: String) async throws {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let data = [
            "goalId" : goalId,
            "dateCreated": Timestamp(date: Date()),
            "uid": uid
        ] as [String : Any]
        
        try await Firestore.firestore().collection("userGoalUpdates").addDocument(data: data)
    }
    
    
    /// Updates that the goals were completed for the current day.
    func updateCompletedForDay() async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let completed = try await Firestore.firestore()
            .collection("userGoalUpdates")
            .whereField("dateCreated", isDateInToday: Date())
            .getDocuments()
            .count
        
        let totalCount = try await Firestore.firestore()
            .collection("goals")
            .whereField("uid", isEqualTo: uid)
            .getDocuments()
            .count
            
        if completed == totalCount {
            let data = [
                "dateCreated": Timestamp(date: Date()),
                "uid": uid
            ] as [String : Any]
            
            try await Firestore.firestore()
                .collection("completedGoalsForDay")
                .addDocument(data: data)
        }
    }
    
    
    /// Checks to see if the goals were completed for the date.
    /// - Parameter selectedDate: The full selected date.
    /// - Returns: Flag weather all of the goals were completed.
    func checkCompletedForDay(selectedDate: Date) async throws -> Bool {
        guard let uid = Auth.auth().currentUser?.uid else { return false }
        
        let calendar = Calendar.current
        guard let startOfNextDay = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: selectedDate)) else {
            fatalError("Could not get next date.")
        }
        
        let startOfToday =  calendar.startOfDay(for: selectedDate)
        
        let docs = try await Firestore.firestore()
            .collection("completedGoalsForDay")
            .whereField("uid", isEqualTo: uid)
            .whereField("dateCreated", isLessThan: Timestamp(date: startOfNextDay))
            .whereField("dateCreated", isGreaterThanOrEqualTo: Timestamp(date: startOfToday))
            .getDocuments()
            .documents
        
        return !docs.isEmpty
    }
    
    /// Fetches weather all of the goals were completed for the month
    /// - Parameter monthComponents: The month component to check
    /// - Returns: A hash map that maps to a date and weather is was completed.
    func fetchCompletedDaysFor(monthComponents: DateComponents) async throws -> [Date: Bool] {
        guard let uid = Auth.auth().currentUser?.uid else { return [:] }

        let calendar = Calendar.current
        guard let startOfMonth = calendar.date(from: monthComponents),
              let monthInterval = calendar.dateInterval(of: .month, for: startOfMonth) else { return [:] }

        let endOfMonth = monthInterval.end.addingTimeInterval(-1)
        var result = [Date: Bool]()

        /// Fetch completed goals from Firestore.
        let docs = try await Firestore.firestore()
            .collection("completedGoalsForDay")
            .whereField("uid", isEqualTo: uid)
            .whereField("dateCreated", isGreaterThanOrEqualTo: Timestamp(date: startOfMonth))
            .whereField("dateCreated", isLessThan: Timestamp(date: endOfMonth))
            .getDocuments()
            .documents

        /// Map Firestore documents to normalized day
        var completedDaysSet: Set<Date> = []
        for doc in docs {
            if let timestamp = doc["dateCreated"] as? Timestamp {
                let day = calendar.startOfDay(for: timestamp.dateValue())
                completedDaysSet.insert(day)
            }
        }

        /// Loop over each day of the month
        var currentDate = startOfMonth
        while currentDate <= endOfMonth {
            let dayStart = calendar.startOfDay(for: currentDate)
            let isCompleted = completedDaysSet.contains(dayStart)
            result[dayStart] = isCompleted
            
            // Move to the next day
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return result
    }
    
    /// Checks to see if a goal update was made the day prior.
    /// - Parameter goalId: The goal id to check.
    /// - Returns: Boolean value if an update was made yesterday.
    func entryAddedYesterday(for goalId: String) async throws -> Bool {
        guard let dayBeforeSelectedDate = Calendar.current.date(byAdding: .day, value: -1, to: Date()) else {
            return false
        }
        
        let snapshot = try await Firestore.firestore()
            .collection("userGoalUpdates")
            .whereField("dateCreated", isDateInToday: dayBeforeSelectedDate)
            .whereField("goalId", isEqualTo: goalId)
            .getDocuments()
        
        return !snapshot.isEmpty
    }
    
    /// Increate the streak for the goal.
    /// - Parameter goalId: The goal id to check.
    func setGoalStreak(for goalId: String, increment: Bool) async throws {
        if increment {
            try await Firestore.firestore()
                .collection("goals")
                .document(goalId)
                .updateData(
                    ["streak": FieldValue.increment(Int64(1))]
                )
        } else {
            try await Firestore.firestore()
                .collection("goals")
                .document(goalId)
                .updateData(
                    ["streak": 1 as Int64]
                )
        }
    }
    
    /// Checks to see if progress updates were made on a goal for a specfic date.
    /// - Parameters:
    ///   - goal: The goal to check.
    ///   - selectedDate: The date to check.
    /// - Returns: Boolean value if a update was made on the day for the goal.
    func checkDailyEntry(for goalId: String, selectedDate: Date) async throws -> Bool {
        guard let uid = Auth.auth().currentUser?.uid else { return false }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let selectedDateString = dateFormatter.string(from: selectedDate)

        let snapshot = try await Firestore.firestore()
            .collection("userGoalUpdates")
            .whereField("uid", isEqualTo: uid)
            .whereField("goalId", isEqualTo: goalId)
            .getDocuments()

        for document in snapshot.documents {
            if let timestamp = document.data()["dateCreated"] as? Timestamp {
                let dateString = dateFormatter.string(from: timestamp.dateValue())
                if dateString == selectedDateString {
                    return true
                }
            }
        }

        return false
    }
    
    /// Delete the goal and the progress made on the goal.
    ///
    /// - Parameter goalId: The goal id which data the delete.
    ///
    func deleteGoalAndHistory(for goal: Goal) async throws {
        guard let goalId = goal.id else { return }
        try await Firestore.firestore().collection("goals").document(goalId).delete()
        
        let snapshot = try await Firestore.firestore()
            .collection("userGoalUpdates")
            .whereField("goalId", isEqualTo: goalId)
            .getDocuments()

        for document in snapshot.documents {
            try await document.reference.delete()
        }
    }
}

