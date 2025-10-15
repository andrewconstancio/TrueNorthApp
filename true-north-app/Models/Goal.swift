import Foundation
import FirebaseFirestore
import CoreData

struct Goal: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var title: String
    var description: String
    var dateCreated: Timestamp
    var complete: Bool
    var category: String
    var uid: String
    var streak: Int
    var endDate: Date? = nil
    
    init?(from data: [String: Any], id: String) {
        guard let title = data["title"] as? String,
              let description = data["description"] as? String,
              let dateCreated = data["dateCreated"] as? Timestamp,
              let complete = data["complete"] as? Bool,
              let category = data["category"] as? String,
              let uid = data["uid"] as? String,
              let steak = data["streak"] as? Int,
              let endDate = data["endDate"] as? Date else {
            return nil
        }

        self.id = id
        self.title = title
        self.description = description
        self.dateCreated = dateCreated
        self.complete = complete
        self.category = category
        self.uid = uid
        self.streak = steak
        self.endDate = endDate
    }
    
    init(id: String = UUID().uuidString,
         title: String,
         description: String,
         dateCreated: Timestamp,
         complete: Bool,
         category: String,
         uid: String,
         streak: Int,
         completedForTheDay: Bool = false,
         endDate: Date?) {
        self.id = id
        self.title = title
        self.description = description
        self.dateCreated = dateCreated
        self.complete = complete
        self.category = category
        self.uid = uid
        self.streak = streak
        self.endDate = endDate
    }
    
    static let dummy = Goal(
        id: UUID().uuidString,
        title: "Learn SwiftUI really deep. I want to get really good.",
        description: "Complete 5 SwiftUI tutorials and build a sample app.",
        dateCreated: Timestamp(date: Date()),
        complete: false,
        category: "Fitness",
        uid: "testUser123",
        streak: 14,
        endDate: nil
    )
    
    mutating func setUID(_ uid: String) {
        self.uid = uid
    }
}

extension GoalEntity {
    var toGoal: Goal {
        Goal(
            id: self.docId ?? "",
            title: self.title ?? "",
            description: self.descriptionGoal ?? "",
            dateCreated: Timestamp(date: self.dateCreated ?? Date()),
            complete: self.completed,
            category: self.category ?? "",
            uid: self.uid ?? "",
            streak: Int(self.streak),
            endDate: self.endDate ?? Date()
        )
    }
}
