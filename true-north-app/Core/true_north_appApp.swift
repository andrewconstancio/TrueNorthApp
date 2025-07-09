//
//  true_north_appApp.swift
//  true-north-app
//
//  Created by Andrew Constancio on 6/19/25.
//

import SwiftUI

@main
struct GoalTrackerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @StateObject var viewModel = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}
