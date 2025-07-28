import SwiftUI

struct ContentView: View {
    
    /// Auth environment view model
    @EnvironmentObject private var viewModel: AuthViewModel
    
    /// Navigation state path for this view
    @State private var path = NavigationPath()
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                SplashView()
            } else if viewModel.userSession == nil {
                authenticationFlow
            } else if viewModel.requiresProfileSetup {
                profileSetupFlow
            } else {
                mainInterfaceView
            }
        }
    }
    
    /// Authentication flow for the main view
    var authenticationFlow: some View {
        NavigationStack(path: $path) {
            LoginView()
                .modifier(NavigationAuth(path: $path))
        }
    }
    
    /// User profile setup flow for the main view
    var profileSetupFlow: some View {
        NavigationStack(path: $path) {
            AddFullNameView()
                .modifier(NavigationAuth(path: $path))
        }
    }
    
    /// Main content view for this app
    var mainInterfaceView: some View {
        MainTabView()
            .accentColor(.primary)
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel()) // Ensure the environment object is provided
}
