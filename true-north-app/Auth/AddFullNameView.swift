import SwiftUI

struct AddFullNameView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @StateObject private var keyboard = KeyboardObserver()
    
    private var isValidName: Bool {
        !viewModel.profileSetup.firstName.isEmpty && !viewModel.profileSetup.lastName.isEmpty && viewModel.profileSetup.firstName.count >= 2 && viewModel.profileSetup.lastName.count >= 2
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            // Name inputs
            VStack(alignment: .leading, spacing: 16) {
                
                Text("What's your name?")
                    .font(FontManager.Bungee.regular.font(size: 24))
                    .foregroundStyle(.textPrimary)
                    .padding(.bottom)
          
                // First name
                CustomInputField(
                    imageName: nil,
                    placeholderText: "First Name",
                    keyboardType: .default,
                    text: $viewModel.profileSetup.firstName
                )
                
                // Last name
                CustomInputField(
                    imageName: nil,
                    placeholderText: "Last Name",
                    keyboardType: .default,
                    text: $viewModel.profileSetup.lastName
                )
                
            }
            .padding()
            
            Spacer()
            
            // Continue button
            NavigationLink(value: AuthRoute.addProfilePicture) {
                Text("Continue")
                    .font(FontManager.Bungee.regular.font(size: 18))
                    .foregroundStyle(.textPrimary)
                    .frame(width: 340, height: 65)
                    .background(isValidName ? Color.themeColor : Color.black.opacity(0.4))
                    .clipShape(Capsule())
                    .padding()
                    .animation(.easeOut(duration: 0.25), value: keyboard.keyboardHeight)
                    .opacity(isValidName ? 1 : 0.5)
            }
        }
        .padding(.bottom, 40)
        .frame(maxWidth: .infinity)
        .background(Color.backgroundPrimary.ignoresSafeArea())
    }
}

#Preview {
    AddFullNameView()
        .environmentObject(AuthViewModel())
}
