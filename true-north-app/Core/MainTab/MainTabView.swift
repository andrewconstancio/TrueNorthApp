import SwiftUI

enum Tab: Hashable {
    case home, explore, settings
}

struct MainTabView: View {
    /// Auth environment view model
    @EnvironmentObject var viewModel: AuthViewModel
    
    /// Selected tab
    @State private var selectedTab: Tab = .home
    
    /// The navigation path for the main views.
    @State private var path: NavigationPath = .init()
    
    /// The goal view model to handle all business logic.
    @StateObject private var goalViewModel = GoalViewModel()

    var body: some View {
        NavigationStack(path: $path) {
            TabView(selection: $selectedTab) {
                NavigationView {
                    LazyView(GoalsListView())
                        .environmentObject(viewModel)
                        .environmentObject(goalViewModel)
                }
                .tabItem { Label("Home", systemImage: "house") }
                .tag(Tab.home)

                NavigationView {
                    LazyView(SettingsView())
                }
                .tabItem { Label("Settings", systemImage: "gear") }
                .tag(Tab.settings)
            }
            .navigationDestination(for: String.self) { string in
                switch string {
                case "GoalsEditView":
                    GoalsEditView(goalViewModel: goalViewModel)
                default:
                    Text("No view has been set for \(string)")
                }
            }
            .navigationDestination(for: Int.self) { value in
                GoalDetailView(
                    goal: goalViewModel.userGoals[value],
                    goalViewModel: goalViewModel
                )
            }
        }
    }
}
