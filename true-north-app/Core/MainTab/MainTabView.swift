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
    @State private var selectedTab: Tab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            GoalsListView()
                .withRootAppearance()
                .tabItem { Label("Home", systemImage: "house") }
                .tag(Tab.home)

            ExploreView()
                .withRootAppearance()
                .tabItem { Label("Explore", systemImage: "magnifyingglass") }
                .tag(Tab.explore)

            SettingsView()
                .withRootAppearance()
                .tabItem { Label("Settings", systemImage: "gear") }
                .tag(Tab.settings)
        }
    }
}


