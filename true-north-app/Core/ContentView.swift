//
//  ContentView.swift
//  true-north-app
//
//  Created by Andrew Constancio on 6/24/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = AuthViewModel()
    
    var body: some View {
        Group {
            if viewModel.userSession == nil {
                LoginView()
                    .modifier(RootViewAppearance())
            } else {
                mainInterfaceView
            }
        }
    }
}

extension ContentView {
    var mainInterfaceView: some View {
        MainTabView()
            .accentColor(.primary)
    }
}

#Preview {
    ContentView()
}
