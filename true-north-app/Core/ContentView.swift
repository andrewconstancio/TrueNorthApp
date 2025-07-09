//
//  ContentView.swift
//  true-north-app
//
//  Created by Andrew Constancio on 6/24/25.
//


import SwiftUI

// MARK: - Navigation Destinations
enum NavigationDestination: String, CaseIterable {
    case addPhoneNumber = "AddPhoneNumberView"
    case addProfilePicture = "AddProfilePictureView"
    case verifyPhoneCode = "VerifyPhoneCodeView"
    case addFullName = "AddFullNameView"
    
    @ViewBuilder
    func view(path: Binding<NavigationPath>) -> some View {
        switch self {
        case .addPhoneNumber:
            AddPhoneNumberView(path: path)
        case .addProfilePicture:
            AddProfilePictureView()
        case .verifyPhoneCode:
            VerifyPhoneCodeView(path: path)
        case .addFullName:
            AddFullNameView()
        }
    }
}

// MARK: - Content View
struct ContentView: View {
    @EnvironmentObject private var viewModel: AuthViewModel
    @State private var path = NavigationPath()
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                LoadingView()
            } else if viewModel.userSession == nil {
                authenticationFlow
            } else if viewModel.requiresProfileSetup {
                profileSetupFlow
            } else {
                mainInterfaceView
            }
        }
    }
}

// MARK: - View Components
private extension ContentView {
    var authenticationFlow: some View {
        NavigationStack(path: $path) {
            LoginView()
                .navigationDestination(for: String.self, destination: navigationDestination)
        }
    }
    
    var profileSetupFlow: some View {
        NavigationStack(path: $path) {
            AddFullNameView()
                .navigationDestination(for: String.self, destination: navigationDestination)
        }
    }
    
    var mainInterfaceView: some View {
        MainTabView()
            .accentColor(.primary)
    }
    
    @ViewBuilder
    func navigationDestination(for string: String) -> some View {
        if let destination = NavigationDestination(rawValue: string) {
            destination.view(path: $path)
                .environmentObject(viewModel)
        } else {
            Text("No view has been set for \(string)")
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    ContentView()
}
