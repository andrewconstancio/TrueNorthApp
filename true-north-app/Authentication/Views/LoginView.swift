import SwiftUI

/// The login view for this app.
struct LoginView: View {
    /// The auth view model.
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        VStack {
            Spacer()
//            logo
            Spacer()
            googleSignInButton
        }
        .padding(.bottom, 40)
    }
    
    /// App logo.
//    private var logo: some View {
//        AdaptiveView {
//            Image("login_light")
//                .resizable()
//                .scaledToFit()
//                .frame(width: 400, height: 440)
//        } dark: {
//            Image("login_dark")
//                .resizable()
//                .scaledToFit()
//                .frame(width: 400, height: 440)
//        }
//    }
    
    /// Google sign in button.
    private var googleSignInButton: some View {
        Button {
              Task {
                  await viewModel.signInGoogle()
              }
          } label: {
              HStack {
                  Image("google")
                      .resizable()
                      .renderingMode(.template)
                      .aspectRatio(contentMode: .fit)
                      .frame(width: 28, height: 28)
                  
                  Text("Sign in with Google")
              }
              .font(.headline)
              .foregroundColor(.white)
              .frame(width: 340, height: 65)
              .background(Color.themeColor)
              .clipShape(Capsule())
              .padding()
          }
    }
}

#Preview {
    LoginView()
}

