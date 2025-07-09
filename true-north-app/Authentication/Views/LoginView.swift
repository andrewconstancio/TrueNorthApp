//
//  LoginView.swift
//  true-north-app
//
//  Created by Andrew Constancio on 6/24/25.
//

import SwiftUI

struct LoginView: View {
//    @State private var path: NavigationPath = .init()
    
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        
//        NavigationStack(path: $path) {
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
//                              path.append("AddFullNameView")
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

//                NavigationLink(value: "AddPhoneNumberView") {
//                    Text("Sign In")
//                        .font(.headline)
//                        .foregroundColor(.white)
//                        .frame(width: 340, height: 65)
//                        .background(Color.themeColor)
//                        .clipShape(Capsule())
//                        .padding()
//                }
            }
            .padding(.bottom, 40)
//            .onChange(of: viewModel.requiresProfileSetup) { needsSetup in
//                if needsSetup {
//                    path.append("AddFullNameView")
//                }
//            }
//            .navigationDestination(for: String.self) { string in
//                switch string{
//                case "AddPhoneNumberView":
//                    AddPhoneNumberView(path: $path)
//                        .modifier(RootViewAppearance())
//                case "AddProfilePictureView":
//                    AddProfilePictureView()
//                        .modifier(RootViewAppearance())
//                case "VerifyPhoneCodeView":
//                    VerifyPhoneCodeView(path: $path)
//                        .modifier(RootViewAppearance())
//                case "AddFullNameView":
//                    AddFullNameView()
//                        .environmentObject(viewModel)
//                        .modifier(RootViewAppearance())
//                default:
//                    Text("No view has been set for \(string)")
//                }
//            }
//        }
    }
}

#Preview {
    LoginView()
}

