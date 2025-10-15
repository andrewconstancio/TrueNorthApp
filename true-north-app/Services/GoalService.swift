import FirebaseFirestore
import FirebaseAuth
import SwiftUI

struct GoalService {
    /// Fetched the goals for a specfic date.
    /// - Parameter selectedDate: The date to select goals from.
    /// - Returns: The goals for the user for the date.
    func fetchGoals(for selectedDate : Date) async throws -> [Goal] {
        guard let uid = Auth.auth().currentUser?.uid else {
            return []
        }
        
        let snapshot = try await Firestore.firestore()
            .collection("goals")
            .whereField("uid", isEqualTo: uid)
            .whereField("dateCreated", isLessThanOrEqualTo: selectedDate)
            .order(by: "dateCreated", descending: true)
            .getDocuments()
        
        let goals = try snapshot.documents.compactMap { doc in
            try doc.data(as: Goal.self)
        }
        
       return goals
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
        
        let increaseStreak = try await yesterdaySavedGoal(for: goalId)
        
        if increaseStreak {
            try await incrementStreak(for: goalId)
        }
    }
    
    
    /// Checks to see if a goal update was made the day prior.
    /// - Parameter goalId: The goal id to check.
    /// - Returns: Boolean value if an update was made yesterday.
    func yesterdaySavedGoal(for goalId: String) async throws -> Bool {
        guard let dayBeforeSelectedDate = Calendar.current.date(byAdding: .day, value: -1, to: Date()) else {
            return false
        }
        
        let snapshot = try await Firestore.firestore()
            .collection("userGoalUpdates")
            .whereField("goalId", isEqualTo: goalId)
            .whereField("dateCreated", isEqualTo: dayBeforeSelectedDate)
            .getDocuments()
        
        return snapshot.isEmpty
    }
    
    
    /// Increate the streak for the goal.
    /// - Parameter goalId: The goal id to check.
    func incrementStreak(for goalId: String) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            Firestore.firestore()
                .collection("goals")
                .document(goalId)
                .updateData([
                    "streak": FieldValue.increment(Int64(1))
                ]) { error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: ())
                    }
                }
        }
    }
    
    /// Checks to see if progress updates were made on a goal for a specfic date.
    /// - Parameters:
    ///   - goal: The goal to check.
    ///   - selectedDate: The date to check.
    /// - Returns: Boolean value if a update was made on the day for the goal.
    func checkIfUpdateMadeGoal(for goal: Goal, selectedDate: Date) async throws -> Bool {
        guard let uid = Auth.auth().currentUser?.uid else { return false }
        guard let goalId = goal.id else { return false }
        
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
    func deleteGoalAndHistory(for goalId: String) async throws {
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
