import SwiftUI

/// The root view for this app. 
struct RootView: View {
    /// Auth environment view model
    @EnvironmentObject private var viewModel: AuthViewModel
    
    /// The goal view model to handle all business logic.
    @StateObject private var goalViewModel = GoalViewModel()
    
    /// Navigation state path for this view
    @State private var path = NavigationPath()
    
    var body: some View {
        switch viewModel.authState {
         case .loading:
             SplashView()
         case .unauthenticated:
             authenticationFlow
         case .requiresSetup:
             profileSetupFlow
         case .authenticated:
             mainInterfaceView
         case .error(let message):
            SplashView()
         }
    }
    
    /// Authentication flow for the main view
    var authenticationFlow: some View {
        NavigationStack(path: $path) {
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
        NavigationStack(path: $path) {
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
        NavigationStack(path: $path) {
            NavigationView {
                LazyView(GoalsListView())
                    .environmentObject(viewModel)
                    .environmentObject(goalViewModel)
            }
            .navigationDestination(for: AppRoutes.self) { route in
                switch route {
                case .goalEdit:
                    GoalsEditView(goalViewModel: goalViewModel)
                }
            }
            .navigationDestination(for: Goal.self) { goal in
                GoalDetailView(
                    goal: goal,
                    selectedDate: goalViewModel.selectedDate
                )
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
