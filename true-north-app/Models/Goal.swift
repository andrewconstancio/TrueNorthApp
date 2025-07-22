import Foundation
import FirebaseFirestore

struct Goal: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var description: String
    var term: String
    var dateCreated: Timestamp
    var complete: Bool
    var uid: String
    var color: String
    
    init?(from data: [String: Any], id: String) {
        guard let title = data["title"] as? String,
              let description = data["description"] as? String,
              let term = data["term"] as? String,
              let dateCreated = data["dateCreated"] as? Timestamp,
              let complete = data["complete"] as? Bool,
              let uid = data["uid"] as? String,
              let color = data["color"] as? String else {
            return nil
        }

        self.id = id
        self.title = title
        self.description = description
        self.term = term
        self.dateCreated = dateCreated
        self.complete = complete
        self.uid = uid
        self.color = color
    }
    
    init(id: String = UUID().uuidString,
         title: String,
         description: String,
         term: String,
         dateCreated: Timestamp,
         complete: Bool,
         uid: String,
         color: String) {
        self.id = id
        self.title = title
        self.description = description
        self.term = term
        self.dateCreated = dateCreated
        self.complete = complete
        self.uid = uid
        self.color = color
    }
    
    static let dummy = Goal(
        id: UUID().uuidString,
        title: "Learn SwiftUI",
        description: "Complete 5 SwiftUI tutorials and build a sample app.",
        term: "Short Term",
        dateCreated: Timestamp(date: Date()),
        complete: false,
        uid: "testUser123",
        color: "#09FFE5"
    )
}
