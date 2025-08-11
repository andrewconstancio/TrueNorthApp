import FirebaseAuth

enum AuthState {
    case loading
    case unauthenticated
    case requiresSetup(FirebaseAuth.User)
    case authenticated(User)
    
    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }
    
    var isAuthenticated: Bool {
        if case .authenticated = self { return true }
        return false
    }
    
    var requiresSetup: Bool {
        if case .requiresSetup = self { return true }
        return false
    }
    
    var currentUser: User? {
        if case .authenticated(let user) = self { return user }
        return nil
    }
    
    var firebaseUser: FirebaseAuth.User? {
        switch self {
        case .requiresSetup(let user):
            return user
        case .authenticated:
            return Auth.auth().currentUser
        default:
            return nil
        }
    }
}
