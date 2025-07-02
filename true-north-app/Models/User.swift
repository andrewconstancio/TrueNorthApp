//
//  User.swift
//  true-north-app
//
//  Created by Andrew Constancio on 7/2/25.
//

import FirebaseAuth
import FirebaseFirestore

struct User: Identifiable, Decodable {
    @DocumentID var id: String?
    let username: String
    let fullname: String
    let profileImageUrl: String?
    let email: String
}

extension User {
    var avatarUrl: String {
        profileImageUrl ?? "https://www.gravatar.com/avatar/205e460b479e2e5b48aec07710c08d50"
    }
        
    var isCurrentUser: Bool {
        Auth.auth().currentUser?.uid == id
    }
}
