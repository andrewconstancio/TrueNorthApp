import SwiftUI

struct VerifyPhoneCodeView: View {
    @Binding var path: NavigationPath
    
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var verificationCode: String = ""
    @State private var showError: Bool = false
    @State private var errorMessage: TNError?
    @StateObject private var keyboard = KeyboardObserver()
    
    private var isValidCode: Bool {
        verificationCode.count == 6
    }
    
    init(path: Binding<NavigationPath>) {
        self._path = path
        print("VerifyPhoneCodeView init")
    }
    
    var body: some View {
        VStack {
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 16) {
                Text("Enter verification code")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Please enter the six-digit code sent to your phone number.")
                    .font(.caption)
                    .fontWeight(.bold)
                
                CustomInputField(
                    imageName: nil,
                    placeholderText: "123456",
                    keyboardType: .phonePad,
                    maxLength: 6,
                    text: $verificationCode
                )
            }
            .padding()
            
            Spacer()
            
            VStack(alignment: .center, spacing: 16) {
                
                Button {
                    // TODO: resend the code
                } label: {
                    Text("Resend Code")
                        .font(.caption)
                        .fontWeight(.bold)
                }
                
                Button {
                    Task {
                        do {
                            // Navigate to next view
                            path.append("AddFullNameView")
                            try await viewModel.verifyOPTCode(verificationCode: verificationCode)
                        } catch {
                            showError = true
                            errorMessage = error as? TNError
                        }
                    }
                } label: {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 340, height: 65)
                        .background(isValidCode ? Color.themeColor : Color.black.opacity(0.4))
                        .clipShape(Capsule())
                        .padding()
                        .animation(.easeOut(duration: 0.25), value: keyboard.keyboardHeight)
                        .opacity(isValidCode ? 1 : 0.5)
                }
            }
        }
        .alert(isPresented: $showError, error: errorMessage, actions: {_ in
            
        }, message: { error in
            Text("Please try again.")
        })
        .padding(.bottom, 60)
    }
}

#Preview {
    VerifyPhoneCodeView(path: .constant(NavigationPath()))
}
