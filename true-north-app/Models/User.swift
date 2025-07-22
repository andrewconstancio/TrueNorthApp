import FirebaseAuth
import FirebaseFirestore

struct User: Identifiable, Decodable {
    @DocumentID var id: String?
    let firstName: String
    let lastName: String
    let profileImageUrl: String?
}

extension User {
    var avatarUrl: String {
        profileImageUrl ?? "https://www.gravatar.com/avatar/205e460b479e2e5b48aec07710c08d50"
    }
        
    var isCurrentUser: Bool {
        Auth.auth().currentUser?.uid == id
    }
}
