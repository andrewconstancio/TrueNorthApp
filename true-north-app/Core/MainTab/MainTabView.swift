import SwiftUI

enum Tab: Hashable {
    case home, explore, settings
}

struct MainTabView: View {
    /// Auth environment view model
    @EnvironmentObject var viewModel: AuthViewModel
    
    /// Selectd tab
    @State private var selectedTab: Tab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                LazyView(GoalsListView())
                    .environmentObject(viewModel)
            }
            .tabItem { Label("Home", systemImage: "house") }
            .tag(Tab.home)

            NavigationView {
                LazyView(SettingsView())
            }
            .tabItem { Label("Settings", systemImage: "gear") }
            .tag(Tab.settings)
        }
    }
}
