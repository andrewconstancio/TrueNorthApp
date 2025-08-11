import Foundation
import FirebaseFirestore

struct Goal: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var title: String
    var description: String
    var dateCreated: Timestamp
    var complete: Bool
    var category: String
    var uid: String
    var streak: Int
    var completedForTheDay: Bool? = false
    
    init?(from data: [String: Any], id: String) {
        guard let title = data["title"] as? String,
              let description = data["description"] as? String,
              let dateCreated = data["dateCreated"] as? Timestamp,
              let complete = data["complete"] as? Bool,
              let category = data["category"] as? String,
              let uid = data["uid"] as? String,
              let steak = data["streak"] as? Int else {
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
    }
    
    init(id: String = UUID().uuidString,
         title: String,
         description: String,
         dateCreated: Timestamp,
         complete: Bool,
         category: String,
         uid: String,
         streak: Int,
         completedForTheDay: Bool = false) {
        self.id = id
        self.title = title
        self.description = description
        self.dateCreated = dateCreated
        self.complete = complete
        self.category = category
        self.uid = uid
        self.streak = streak
        self.completedForTheDay = completedForTheDay
    }
    
    static let dummy = Goal(
        id: UUID().uuidString,
        title: "Learn SwiftUI",
        description: "Complete 5 SwiftUI tutorials and build a sample app.",
        dateCreated: Timestamp(date: Date()),
        complete: false,
        category: "Fitness",
        uid: "testUser123",
        streak: 14,
        completedForTheDay: true
    )
    
    mutating func setUID(_ uid: String) {
        self.uid = uid
    }
    
    mutating func setCompletedForTheDay(_ completedForTheDay: Bool) {
        self.completedForTheDay = completedForTheDay
    }
}
