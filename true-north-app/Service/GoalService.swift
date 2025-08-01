import FirebaseFirestore
import FirebaseAuth
import SwiftUI

struct GoalService {
    func saveGoal(title: String, description: String, term: String, endDate: Date, color: String) async throws {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let userData = ["title": title,
                        "description": description,
                        "term": term,
                        "dateCreated": Timestamp(date: Date()),
                        "endDate": Timestamp(date: endDate),
                        "complete": false,
                        "color": color,
                        "uid": uid] as [String : Any]
        
        do {
            try await Firestore.firestore().collection("goals").addDocument(data: userData)
        } catch {
            throw TNError.generalError
        }
    }
    
    func fetchGoals(for selectedDate : Date) async throws -> [Goal] {
        guard let uid = Auth.auth().currentUser?.uid else {
            return []
        }
        
        do {
            
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
        } catch {
            throw TNError.generalError
        }
    }
    
    func saveProgress(for goalId: String) async throws {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let data = [
            "goalId" : goalId,
            "dateCreated": Timestamp(date: Date()),
            "uid": uid
        ] as [String : Any]
        
        do {
            try await Firestore.firestore().collection("userGoalUpdates").addDocument(data: data)
        } catch {
            throw TNError.generalError
        }
    }
    
    func checkIfUpdateMadeGoal(for goal: Goal, selectedDate: Date) async throws -> Bool {
        guard let uid = Auth.auth().currentUser?.uid else { return false }
        guard let goalId = goal.id else { return false }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let selectedDateString = dateFormatter.string(from: selectedDate)

        do {
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
        } catch {
            throw TNError.generalError
        }
    }
    
    func deleteGoalAndHistory(for goalId: String) async throws {
        
        // Delete the goal
        try await Firestore.firestore().collection("goals").document(goalId).delete()
        
        // Delete the updates made from the user on the goal
        do {
            let snapshot = try await Firestore.firestore()
                .collection("userGoalUpdates")
                .whereField("goalId", isEqualTo: goalId)
                .getDocuments()

            for document in snapshot.documents {
                try await document.reference.delete()
            }
        } catch {
            throw TNError.generalError
        }
    }
}
