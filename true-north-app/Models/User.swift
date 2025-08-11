import FirebaseAuth
import FirebaseFirestore

struct User: Identifiable, Decodable {
    @DocumentID var id: String?
    let firstName: String
    let lastName: String
    let profileImageUrl: String?
    let dateCreated: Timestamp
    
    var isCurrentUser: Bool {
        Auth.auth().currentUser?.uid == id
    }
    
    var daysSinceCreated: Int {
        let createdDate = dateCreated.dateValue()
        let today = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: createdDate, to: today)
        return components.day ?? 0
    }
    
    static var dummy: User {
        User (
            id: nil,
            firstName: "John",
            lastName: "Snow",
            profileImageUrl: "https://www.gravatar.com/avatar/205e460b479e2e5b48aec07710c08d50",
            dateCreated: Timestamp(date: Date())
        )
    }
}
