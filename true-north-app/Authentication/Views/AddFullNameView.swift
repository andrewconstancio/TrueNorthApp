import SwiftUI

struct AddFullNameView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @StateObject private var keyboard = KeyboardObserver()
    
    private var isValidName: Bool {
        !viewModel.setupFirstName.isEmpty && !viewModel.setupLastName.isEmpty && viewModel.setupLastName.count >= 2 && viewModel.setupLastName.count >= 2
    }
    
    var body: some View {
        VStack {
            
            Spacer()
            
            // Name inputs
            VStack(alignment: .leading, spacing: 16) {
                
                Text("What's your name?")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.bottom)
          
                // First name
                CustomInputField(
                    imageName: nil,
                    placeholderText: "First Name",
                    keyboardType: .default,
                    text: $viewModel.setupFirstName
                )
                
                // Last name
                CustomInputField(
                    imageName: nil,
                    placeholderText: "Last Name",
                    keyboardType: .default,
                    text: $viewModel.setupLastName
                )
                
            }
            .padding()
            
            Spacer()
            
            // Continue button
            NavigationLink(value: "AddProfilePictureView") {
                Text("Continue")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 340, height: 65)
                    .background(isValidName ? Color.themeColor : Color.black.opacity(0.4))
                    .clipShape(Capsule())
                    .padding()
                    .animation(.easeOut(duration: 0.25), value: keyboard.keyboardHeight)
                    .opacity(isValidName ? 1 : 0.5)
            }
        }
        .padding(.bottom, 40)
    }
}

#Preview {
    AddFullNameView()
}
