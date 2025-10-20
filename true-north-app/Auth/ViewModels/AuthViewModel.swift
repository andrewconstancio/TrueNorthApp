import SwiftUI
import Firebase
import FirebaseAuth
import GoogleSignIn

/// View model managing authentication state and user profile operations.
///
/// Handles:
/// - Google Sign-In authentication
/// - User profile setup and updates
/// - Authentication state management
/// - Navigation between auth and app flows
///
@MainActor
class AuthViewModel: ObservableObject {
    /// Current authentication state (loading, unauthenticated, requiresSetup, authenticated).
    @Published var authState: AuthState = .loading
    
    /// Temporary data holder for new user profile setup.
    @Published var profileSetup = ProfileSetup()
    
    /// Optional error to display to the user.
    @Published var appError: AppError?
    
    /// Navigation path for authentication flow (login, profile setup).
    @Published var authPath = NavigationPath()
    
    /// Navigation path for main app flow (goals, settings).
    @Published var appPath = NavigationPath()
    
    /// Firebase service for database and storage operations.
    let firebaseService: FirebaseServiceProtocol
    
    /// Temporary Firebase user session during profile setup.
    private var tempUserSession: FirebaseAuth.User?
    
    /// Initializes the auth view model and checks current authentication status.
    ///
    /// - Parameter firebaseService: The Firebase service for data operations.
    ///
    init(firebaseService: FirebaseServiceProtocol) {
        self.firebaseService = firebaseService
        Task {
            await initializeAuth()
        }
    }
    
    /// Initializes authentication state by checking if a user is currently logged in.
    ///
    /// Sets state to:
    /// - `.unauthenticated` if no user is signed in
    /// - Checks profile status if user exists
    ///
    private func initializeAuth() async {
        guard let currentUser = Auth.auth().currentUser else {
            authState = .unauthenticated
            return
        }
        
        await checkUserProfileStatus(for: currentUser)
    }
    
    /// Checks if the user has completed profile setup in Firestore.
    ///
    /// Sets state to:
    /// - `.requiresSetup` if user document doesn't exist
    /// - `.authenticated` if user document exists and data is loaded
    ///
    /// - Parameter firebaseUser: The Firebase Auth user to check.
    ///
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
          appError = AppError.customError(message: "Failed to check user profile: \(error.localizedDescription)")
      }
    }
    
    /// Fetches user data from Firestore and updates authentication state.
    ///
    /// - Parameter uid: The user's unique identifier.
    ///
    private func fetchAndSetUser(uid: String) async {
      await withCheckedContinuation { continuation in
          firebaseService.fetchUser(withUid: uid) { [weak self] user in
              guard let self = self else {
                  continuation.resume()
                  return
              }
              self.authState = .authenticated(user)
              continuation.resume()
          }
      }
    }
    
    /// Signs out the current user and resets auth state.
    ///
    /// Clears:
    /// - Firebase Auth session
    /// - Profile setup data
    /// - Sets state to `.unauthenticated`
    ///
    func logout() {
        do {
            try Auth.auth().signOut()
            authState = .unauthenticated
            profileSetup = ProfileSetup()
        } catch {
            appError = AppError.customError(message: "Failed to log out: \(error.localizedDescription)")
        }
    }
    
    /// Initiates Google Sign-In flow.
    ///
    /// Process:
    /// 1. Gets Firebase client ID
    /// 2. Shows Google Sign-In UI
    /// 3. Exchanges Google token for Firebase credential
    /// 4. Signs into Firebase
    /// 5. Checks if user needs profile setup
    ///
    func signInGoogle() async {
       do {
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
           appError = AppError.customError(message: "Sign in failed: \(error.localizedDescription)")
       }
   }
    
    /// Saves new user profile data to Firestore after initial setup.
    ///
    /// Uploads:
    /// - First and last name
    /// - Account creation date
    /// - Profile image (if provided)
    ///
    /// Then fetches and sets the complete user data in auth state.
    ///
    func saveUserProfile() async {
        guard case .requiresSetup(let firebaseUser) = authState else {
            appError = AppError.customError(message: "Invalid state for profile setup")
            return
        }
        
        guard profileSetup.isValid else {
            appError = AppError.customError(message: "Please fill in all required fields")
            return
        }
        
        do {
            authState = .loading
            
            let userData: [String: Any] = [
                "firstName": profileSetup.firstName.trimmingCharacters(in: .whitespacesAndNewlines),
                "lastName": profileSetup.lastName.trimmingCharacters(in: .whitespacesAndNewlines),
                "dateCreated": Timestamp(date: Date())
            ]
            
            try await Firestore.firestore()
                .collection("users")
                .document(firebaseUser.uid)
                .setData(userData)
            
            if let image = profileSetup.profileImage {
                await saveProfileImage(uid: firebaseUser.uid, image: image)
            }
            
            profileSetup = ProfileSetup()
            await fetchAndSetUser(uid: firebaseUser.uid)
            
        } catch {
            appError = AppError.customError(message: "Failed to save profile: \(error.localizedDescription)")
        }
    }
    
    /// Uploads a new profile image to Firebase Storage and updates Firestore.
    ///
    /// - Parameters:
    ///   - uid: The user's unique identifier.
    ///   - image: The profile image to upload.
    ///   - refreshUser: If `true`, fetches updated user data after saving (default: `false`).
    ///
    func saveProfileImage(uid: String, image: UIImage, refreshUser: Bool = false) async {
        do {
            let downloadUrl = try await StorageFirebaseService.uploadImage(image: image)
            
            try await Firestore.firestore()
                .collection("users")
                .document(uid)
                .updateData(["profileImageUrl": downloadUrl])
            
            if refreshUser {
                await fetchAndSetUser(uid: uid)
            }
        } catch {
            print(error.localizedDescription)
        }
    }

    
    /// Updates multiple user profile fields in a single Firebase call.
    ///
    /// More efficient than updating fields individually.
    /// Automatically refreshes user data after update to reflect changes in UI.
    ///
    /// - Parameter fields: Dictionary of field names and their new values (e.g., `["firstName": "John", "lastName": "Doe"]`).
    ///
    func updateUserFields(_ fields: [String: Any]) async {
        do {
            guard let userId = authState.currentUser?.id else { return }
            
            // Single Firebase call to update multiple fields
            try await Firestore.firestore()
                .collection("users")
                .document(userId)
                .updateData(fields)
            
            // Refresh user data to update UI
            await fetchAndSetUser(uid: userId)
        } catch {
            print("Failed to update user fields: \(error.localizedDescription)")
            appError = AppError.customError(message: "Failed to update profile")
        }
    }
}
