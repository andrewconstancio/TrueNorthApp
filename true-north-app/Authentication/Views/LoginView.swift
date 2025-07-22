import SwiftUI

struct LoginView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        VStack {
            Spacer()
            
            // Logo
            AdaptiveView {
                Image("login_light")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 400, height: 440)
            } dark: {
                Image("login_dark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 400, height: 440)
            }
            
            Spacer()
            
            // Google sign in
            Button {
                  Task {
                      do {
                          try await viewModel.signInGoogle()
                      } catch {
                          
                      }
                  }
              }label: {
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
        .padding(.bottom, 40)
    }
}

#Preview {
    LoginView()
}

