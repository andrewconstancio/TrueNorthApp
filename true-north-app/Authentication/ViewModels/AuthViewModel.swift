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

class AuthViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var userSession: FirebaseAuth.User?
    @Published var verificationID: String?
    @Published var verificationSent = false
    @Published var phoneCredential: PhoneAuthCredential?
    @Published var credentialValid = false
    @Published var errorMessage: String?
    
    private let service = UserService()
    
    init() {
        self.userSession = Auth.auth().currentUser
    }
    
    // MARK: - Fetch User
    func fetchUser() {
        guard let uid = self.userSession?.uid else { return }
        
        print(uid)
        
        service.fetchUser(withUid: uid) { user in
            self.currentUser = user
        }
    }

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
        let scene = await UIApplication.shared.connectedScenes.first as? UIWindowScene
        guard let rootViewController = await scene?.windows.first?.rootViewController
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
        try await Auth.auth().signIn(with: credential)
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
