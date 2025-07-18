//
//  MainTabView.swift
//  true-north-app
//
//  Created by Andrew Constancio on 6/24/25.
//
import SwiftUI

enum Tab: Hashable {
    case home, explore, settings
}

struct MainTabView: View {
    @EnvironmentObject var viewModel: AuthViewModel
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
