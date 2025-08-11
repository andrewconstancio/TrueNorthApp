import SwiftUI
import Firebase
import FirebaseAuth
import GoogleSignIn

@MainActor
class AuthViewModel: ObservableObject {
    /// Current authentication state.
    @Published var authState: AuthState = .loading
    
    /// Profile setup data.
    @Published var profileSetup = ProfileSetup()
    
    /// User Service.
    private let service = UserService()
    
    /// Temp User Session.
    private var tempUserSession: FirebaseAuth.User?
    
    init() {
        Task {
            await initializeAuth()
        }
    }
    
    /// Initializes authentication state
    private func initializeAuth() async {
        guard let currentUser = Auth.auth().currentUser else {
            authState = .unauthenticated
            return
        }
        
        await checkUserProfileStatus(for: currentUser)
    }
    
    /// Checks if user needs profile setup or loads existing user
    private func checkUserProfileStatus(for firebaseUser: FirebaseAuth.User) async {
      let userDocRef = Firestore.firestore().collection("users").document(firebaseUser.uid)
      
      do {
          let snapshot = try await userDocRef.getDocument()
          
          if snapshot.exists {
              await fetchAndSetUser(uid: firebaseUser.uid)
          } else {
              authState = .requiresSetup(firebaseUser)
          }
      } catch {
          authState = .error("Failed to check user profile: \(error.localizedDescription)")
      }
    }
    
    /// Fetches user data and updates auth state
    private func fetchAndSetUser(uid: String) async {
      await withCheckedContinuation { continuation in
          service.fetchUser(withUid: uid) { [weak self] user in
              guard let self = self else {
                  continuation.resume()
                  return
              }
              self.authState = .authenticated(user)
              continuation.resume()
          }
      }
    }
    
    /// Logs out the current user.
    func logout() throws {
        do {
            try Auth.auth().signOut()
            authState = .unauthenticated
            profileSetup = ProfileSetup()
        } catch {
            authState = .error("Failed to log out: \(error.localizedDescription)")
        }
    }
    
    /// Clears any error messages
     func clearError() {
         if case .error = authState {
             authState = .unauthenticated
         }
     }
    
    /// Signs in through Google.
    func signInGoogle() async {
       do {
           authState = .loading
           
           // Get Firebase client ID
           guard let clientID = FirebaseApp.app()?.options.clientID else {
               throw AppError.networkError("Firebase configuration error")
           }

           // Configure Google Sign In
           let config = GIDConfiguration(clientID: clientID)
           GIDSignIn.sharedInstance.configuration = config
           
           // Get root view controller
           guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                 let rootViewController = scene.windows.first?.rootViewController else {
               throw AppError.networkError("Unable to find root view controller")
           }
           
           // Perform Google Sign In
           let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
           let user = result.user
           
           guard let idToken = user.idToken?.tokenString else {
               throw AppError.networkError("Failed to get ID token")
           }
           
           // Sign in with Firebase
           let credential = GoogleAuthProvider.credential(
               withIDToken: idToken,
               accessToken: user.accessToken.tokenString
           )
           let authResult = try await Auth.auth().signIn(with: credential)
           
           // Check if user profile exists
           await checkUserProfileStatus(for: authResult.user)
           
       } catch {
           authState = .error("Sign in failed: \(error.localizedDescription)")
       }
   }
    
    /// Saves the user date.
    func saveUserProfile() async {
        guard case .requiresSetup(let firebaseUser) = authState else {
            authState = .error("Invalid state for profile setup")
            return
        }
        
        guard profileSetup.isValid else {
            authState = .error("Please fill in all required fields")
            return
        }
        
        do {
            authState = .loading
            
            let userData: [String: Any] = [
                "firstName": profileSetup.firstName.trimmingCharacters(in: .whitespacesAndNewlines),
                "lastName": profileSetup.lastName.trimmingCharacters(in: .whitespacesAndNewlines),
                "uid": firebaseUser.uid
            ]
            
            try await Firestore.firestore()
                .collection("users")
                .document(firebaseUser.uid)
                .setData(userData)
            
            if let image = profileSetup.profileImage {
                let downloadUrl = try await ImageUploader.uploadImage(image: image)
                try await Firestore.firestore()
                    .collection("users")
                    .document(firebaseUser.uid)
                    .updateData(["profileImageUrl": downloadUrl])
            }
            
            profileSetup = ProfileSetup()
            await fetchAndSetUser(uid: firebaseUser.uid)
            
        } catch {
            authState = .error("Failed to save profile: \(error.localizedDescription)")
        }
    }
}
