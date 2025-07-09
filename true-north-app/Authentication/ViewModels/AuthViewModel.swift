//
//  AuthViewModel.swift
//  true-north-app
//
//  Created by Andrew Constancio on 6/25/25.
//
import SwiftUI
import Firebase
import FirebaseAuth
import GoogleSignIn

@MainActor
class AuthViewModel: ObservableObject {
    /// Current user object
    @Published var currentUser: User?
    
    /// User session
    @Published var userSession: FirebaseAuth.User?
    
    /// Account requires setup
    @Published var requiresProfileSetup = false
    
    /// Loading state for initial authentication check
    @Published var isLoading = true
    
    /// Error message
    @Published var errorMessage: String?
    
    /// Setup First Name
    @Published var setupFirstName: String = ""
    
    /// Setup Last Name
    @Published var setupLastName: String = ""
    
    /// Setup Profile image
    @Published var setupProfileImage: UIImage?
    
    /// User Service
    private let service = UserService()
    
    /// Temp User Session
    private var tempUserSession: FirebaseAuth.User?
    
    init() {
        self.userSession = Auth.auth().currentUser
        
        // Only check profile setup if we have a user session
        if self.userSession != nil {
            Task {
                await checkIfUserNeedsProfileSetup()
            }
        } else {
            self.isLoading = false
        }
    }
    
    // MARK: - Check User Account
    
    func checkIfUserNeedsProfileSetup() async {
        defer { self.isLoading = false } // Always set loading to false when done
        
        guard let user = Auth.auth().currentUser else {
            self.isLoading = false
            return
        }
        
        let userDocRef = Firestore.firestore().collection("users").document(user.uid)
        
        do {
            let snapshot = try await userDocRef.getDocument()
            if snapshot.exists {
                self.fetchUser()
                self.requiresProfileSetup = false
            } else {
                // Firestore document does not exist yet
                self.requiresProfileSetup = true
            }
        } catch {
            self.errorMessage = "Failed to check user profile"
        }
    }
    
    // MARK: - Fetch User
    
    func fetchUser() {
        guard let uid = self.userSession?.uid else {
            return 
        }
        
        service.fetchUser(withUid: uid) { [weak self] user in
            guard let self = self else { return }
            self.currentUser = user
        }
    }
    
    // MARK: - Sign Out
    
    func logout() {
        print("LOGGING OUT USER")
        userSession = nil
        tempUserSession = nil
        currentUser = nil
        requiresProfileSetup = false
        try? Auth.auth().signOut()
    }
    
    // MARK: - Google sign in
    
    func signInGoogle() async throws {
        // google sign in
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            fatalError("no firbase clientID found")
        }

        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        //get rootView
        let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        guard let rootViewController = scene?.windows.first?.rootViewController
        else {
            fatalError("There is no root view controller!")
        }
        
        //google sign in authentication response
        let result = try await GIDSignIn.sharedInstance.signIn(
            withPresenting: rootViewController
        )
        let user = result.user
        guard let idToken = user.idToken?.tokenString else {
            throw TNError.generalError
        }
        
        //Firebase auth
        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken, accessToken: user.accessToken.tokenString
        )
        let authResult = try await Auth.auth().signIn(with: credential)
        
        let firebaseUser = authResult.user
        
        self.tempUserSession = firebaseUser

        let userDocRef = Firestore.firestore().collection("users").document(firebaseUser.uid)
        let snapshot = try await userDocRef.getDocument()
        
        if snapshot.exists {
            self.userSession = firebaseUser
            self.fetchUser()
            self.requiresProfileSetup = false
        } else {
            self.userSession = firebaseUser
            self.requiresProfileSetup = true
        }
    }
    
    func saveUser() async throws {
        guard let uid = userSession?.uid else {
            return
        }
        guard let image = setupProfileImage else {
            return
        }
        let userData = ["firstName": setupFirstName,
                        "lastName": setupLastName,
                        "uid": uid]
        do {
            try Firestore.firestore().collection("users").document(uid).setData(from: userData)
            let downloadUrl = try await ImageUploader.uploadImage(image: image)
            
            try await Firestore.firestore().collection("users").document(uid).updateData(["profileImageUrl": downloadUrl])
            self.requiresProfileSetup = false
        } catch {
            print(error.localizedDescription)
            throw TNError.generalError
        }
    }

    @Published var verificationID: String?
    @Published var verificationSent = false
    @Published var phoneCredential: PhoneAuthCredential?
    @Published var credentialValid = false
}

extension AuthViewModel {
    
    // MARK: - Register phone number
    
    func registerPhoneNumber(phoneNumber: String) async throws {
        
        let numbersOnly = phoneNumber.filter { $0.isNumber }
        let number = "+1\(numbersOnly)"
        
        do {
            verificationID = try await PhoneAuthProvider.provider().verifyPhoneNumber(number)
            verificationSent = true
        } catch {
            throw TNError.generalError
        }
    }
    
    // MARK: - Verify OPT code
    
    func verifyOPTCode(verificationCode: String) async throws {
        
        guard let verificationID = self.verificationID else {
            throw TNError.generalError
        }
        
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: verificationCode)
        
        do {
            try await Auth.auth().signIn(with: credential)
            phoneCredential = credential
        } catch {
            throw TNError.generalError
        }
    }
    
    // MARK: - format the phone number

    func formatUSPhoneNumber(_ number: String) -> String {
        // Extract digits only
        let digits = number.filter { $0.isWholeNumber }

        // Ensure exactly 10 digits for local US number
        guard digits.count == 10 else {
            return number // fallback: return unformatted if not 10 digits
        }

        let areaCode = digits.prefix(3)
        let middle = digits.dropFirst(3).prefix(3)
        let last = digits.suffix(4)

        return "+1\(areaCode)\(middle)\(last)"
    }
} 
