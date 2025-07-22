import SwiftUI

// MARK: - Navigation Destinations
enum NavigationDestination: String, CaseIterable {
    case addPhoneNumber = "AddPhoneNumberView"
    case addProfilePicture = "AddProfilePictureView"
    case verifyPhoneCode = "VerifyPhoneCodeView"
    case addFullName = "AddFullNameView"
    
    @ViewBuilder
    func view(path: Binding<NavigationPath>) -> some View {
        switch self {
        case .addPhoneNumber:
            AddPhoneNumberView(path: path)
        case .addProfilePicture:
            AddProfilePictureView()
        case .verifyPhoneCode:
            VerifyPhoneCodeView(path: path)
        case .addFullName:
            AddFullNameView()
        }
    }
}

// MARK: - Content View
struct ContentView: View {
    
    /// Auth environment view model
    @EnvironmentObject private var viewModel: AuthViewModel
    
    /// Navigation state path for this view
    @State private var path = NavigationPath()
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                LoadingView()
            } else if viewModel.userSession == nil {
                authenticationFlow
            } else if viewModel.requiresProfileSetup {
                profileSetupFlow
            } else {
                mainInterfaceView
            }
        }
    }
    
    /// Authication flow for the main view..
    var authenticationFlow: some View {
        NavigationStack(path: $path) {
            LoginView()
                .navigationDestination(for: String.self, destination: navigationDestination)
        }
    }
    
    /// User profile set up for the main view.
    var profileSetupFlow: some View {
        NavigationStack(path: $path) {
            AddFullNameView()
                .navigationDestination(for: String.self, destination: navigationDestination)
        }
    }
    
    /// Main content view for this app.
    var mainInterfaceView: some View {
        MainTabView()
            .accentColor(.primary)
    }
    
    @ViewBuilder
    func navigationDestination(for string: String) -> some View {
        if let destination = NavigationDestination(rawValue: string) {
            destination.view(path: $path)
                .environmentObject(viewModel)
        } else {
            Text("No view has been set for \(string)")
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    ContentView()
}
