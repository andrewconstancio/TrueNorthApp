import SwiftUI

/// The root view for this app. 
struct RootView: View {
    
    /// Firebase service from environment - used for passing to child views.
    @Environment(\.firebaseService) private var firebaseService
    
    /// The auth view model state object.
    @StateObject private var authVM: AuthViewModel
    
    /// The goal view model to handle all business logic.
    @StateObject private var goalViewModel: GoalViewModel
    
    /// Initialize RootView with pre-configured ViewModels.
    /// We need to pass firebaseService here because @StateObject needs to be initialized
    /// in init(), but @Environment values aren't available yet.
    init(authVM: AuthViewModel, goalViewModel: GoalViewModel) {
        self._authVM = StateObject(wrappedValue: authVM)
        self._goalViewModel = StateObject(wrappedValue: goalViewModel)
    }
    
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
                .environmentObject(authVM)
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
                .environmentObject(authVM)
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
                    GoalAddEditView(
                        goal: nil,
                        goalAddEditVM: GoalAddEditViewModel(
                            editGoal: nil,
                            firebaseService: firebaseService
                        )
                    )
                case .goalDetail(let goal):
                    GoalDetailView(
                        goal: goal,
                        goalDetailVM: GoalDetailViewModel(
                            goal: goal, firebaseService: firebaseService
                        )
                    )
                }
            }
        }
        .tint(.textPrimary)
        .accentColor(.textBlack)
    }
}

//#Preview {
//    RootView()
//        .environmentObject(AuthViewModel())
//}
