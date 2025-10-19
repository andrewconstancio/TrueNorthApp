import SwiftUI

/// The root view for this app. 
struct RootView: View {
    /// Auth environment view model
    @EnvironmentObject private var authVM: AuthViewModel
    
    /// The goal view model to handle all business logic.
    @StateObject private var goalViewModel = GoalViewModel()
    
    var body: some View {
        switch authVM.authState {
         case .loading:
             SplashView()
         case .unauthenticated:
             authenticationFlow
         case .requiresSetup:
             profileSetupFlow
         case .authenticated:
             mainInterfaceView
         }
    }
    
    /// Authentication flow for the main view
    var authenticationFlow: some View {
        NavigationStack(path: $authVM.authPath) {
            LoginView()
                .navigationDestination(for: AuthRoute.self) { route in
                    switch route {
                    case .addProfilePicture:
                        AddProfilePictureView()
                    case .addFullName:
                        AddFullNameView()
                    }
                }
        }
    }
    
    /// User profile setup flow for the main view
    var profileSetupFlow: some View {
        NavigationStack(path: $authVM.authPath) {
            AddFullNameView()
                .navigationDestination(for: AuthRoute.self) { route in
                    switch route {
                    case .addProfilePicture:
                        AddProfilePictureView()
                    case .addFullName:
                        AddFullNameView()
                    }
                }
        }
    }
    
    /// Main content view for this app
    var mainInterfaceView: some View {
        NavigationStack(path: $authVM.appPath) {
            LazyView(
                GoalsListView()
            )
            .environmentObject(authVM)
            .environmentObject(goalViewModel)
            .navigationDestination(for: AppRoutes.self) { route in
                switch route {
                case .goalAddVew:
                    GoalAddView()
                }
            } 
            .navigationDestination(for: Goal.self) { goal in
                GoalDetailView(goal: goal)
            }
        }
        .tint(.textPrimary)
        .accentColor(.textBlack)
    }
}

#Preview {
    RootView()
        .environmentObject(AuthViewModel())
}
