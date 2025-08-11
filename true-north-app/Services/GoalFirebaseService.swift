import FirebaseFirestore
import FirebaseAuth
import SwiftUI
import CoreData

struct GoalFirebaseService {
    let persistenceController: PersistenceController

    init(persistenceController: PersistenceController = .shared) {
        self.persistenceController = persistenceController
    }
    
    /// Fetched the goals for a specfic date.
    /// - Parameter selectedDate: The date to select goals from.
    /// - Returns: The goals for the user for the date.
    func fetchGoals(selectedDate: Date) async throws -> [Goal] {
        guard let uid = Auth.auth().currentUser?.uid else { return [] }

        let calendar = Calendar.current
        guard let startOfNextDay = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: selectedDate)) else {
            fatalError("Could not get next date.")
        }
        
//        deleteAllData("GoalEntity")
        
//        let cachedGoals = try fetchCachedGoals(startOfNextDay: startOfNextDay)
        
//        if !cachedGoals.isEmpty {
//            print("GOALS FROM CACHE")
//            return cachedGoals
//        }

        let snapshot = try await Firestore.firestore()
            .collection("goals")
            .whereField("uid", isEqualTo: uid)
            .whereField("dateCreated", isLessThan: Timestamp(date: startOfNextDay))
            .order(by: "dateCreated", descending: true)
            .getDocuments()

        let goals = try snapshot.documents.compactMap { doc in
            try doc.data(as: Goal.self)
        }
        
//        guard let yesterday = calendar.date(byAdding: .day, value: -1, to: Date()) else {
//            fatalError("Could not get next date.")
//        }
        
//        if selectedDate < yesterday {
//            cacheGoal(goals)
//        }
        
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
    }
    
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
        } else {
            let docs = try await Firestore.firestore()
                .collection("completedGoalsForDay")
                .whereField("uid", isEqualTo: uid)
                .getDocuments()
                .documents
            
            for doc in docs {
                try await doc.reference.delete()
            }
        }
    }
    
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
        
//        print("startOfNextDay: \(startOfNextDay)")
//        print("startOfToday: \(startOfToday)")
//        print("docs: \(docs.count)")
//        print("docs.isEmpty: \(!docs.isEmpty)")
        
        return !docs.isEmpty
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
    
//    func fetchCachedGoals(startOfNextDay: Date) throws -> [Goal] {
//        let context = persistenceController.container.viewContext
//        let request: NSFetchRequest<GoalEntity> = GoalEntity.fetchRequest()
//        
//        request.predicate = NSPredicate(format: "%K <= %@", #keyPath(GoalEntity.dateCreated), startOfNextDay as NSDate)
//        
//        do {
//            let goals: [GoalEntity] = try context.fetch(request)
//            return goals.map(\.toGoal)
//        } catch {
//            print("ERROR: Failed to fetch goals from CoreData")
//            return []
//        }
//    }
    
//    func cacheGoal(_ goals: [Goal]) {
//        let context = persistenceController.container.viewContext
//        
//        for goal in goals {
//            let newGoal = GoalEntity(context: context)
//            newGoal.docId = goal.id
//            newGoal.category = goal.category
//            newGoal.descriptionGoal = goal.description
//            newGoal.title = goal.title
//            newGoal.dateCreated = goal.dateCreated.dateValue()
//            newGoal.endDate = goal.endDate
//            newGoal.completed = goal.complete
//        }
//        
//        do {
//            try context.save()
//            print("saved")
//        } catch {
//            print("ERROR: Failed to save goal to CoreData")
//        }
//    }
    
//    func deleteAllData(_ entity:String) {
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
//        fetchRequest.returnsObjectsAsFaults = false
//        do {
//            let results = try persistenceController.container.viewContext.fetch(fetchRequest)
//            for object in results {
//                guard let objectData = object as? NSManagedObject else {continue}
//                persistenceController.container.viewContext.delete(objectData)
//            }
//        } catch let error {
//            print("Detele all data in \(entity) error :", error)
//        }
//    }
    
//    func cacheGoal(_ goals: [Goal]) {
//        let context = persistenceController.container.viewContext
//        
//        for goal in goals {
//            let newGoal = GoalEntity(context: context)
//            newGoal.docId = goal.id
//            newGoal.category = goal.category
//            newGoal.descriptionGoal = goal.description
//            newGoal.title = goal.title
//            newGoal.dateCreated = goal.dateCreated.dateValue()
//            newGoal.endDate = goal.endDate
//            newGoal.completed = goal.complete
//        }
//        
//        do {
//            try context.save()
//            print("saved")
//        } catch {
//            print("ERROR: Failed to save goal to CoreData")
//        }
//    }
}
