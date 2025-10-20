import SwiftUI

/// Main settings view for managing user profile and app preferences.
///
/// Provides options to:
/// - Edit user's full name
/// - Change profile picture
/// - Sign out of the app
///
struct SettingsView: View {
    /// Auth view model for authentication operations.
    @EnvironmentObject var authVM: AuthViewModel
    
    /// Settings view model for managing profile edit state.
    @StateObject private var settingsVM = SettingsViewModel()
    
    /// Flag to show the sign out confirmation alert.
    @State private var showingSignOutAlert = false
    
    /// Flag to show the edit name sheet.
    @State private var showEditNameSheet = false
    
    /// Flag to show the edit profile picture sheet.
    @State private var showEditProfilePictureSheet = false
    
    var body: some View {
        VStack {
            Text("Settings")
                .foregroundStyle(.textSecondary)
                .font(FontManager.Bungee.regular.font(size: 16))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 16)
            
            ScrollView {
                VStack(spacing: 22) {
                    // Change the users name.
                    SettingsRow(
                        title: "Change name",
                        icon: "tag.fill",
                        action: {
                            showEditNameSheet = true
                        }
                    )
                    
                    // Change the users profile picture.
                    SettingsRow(
                        title: "Change profile picture",
                        icon: "person.fill",
                        action: {
                            showEditProfilePictureSheet = true
                        }
                    )
                    
                    // Sign out.
                    SettingsRow(
                        title: "Sign out",
                        icon: "hand.wave.fill",
                        action: {
                            showingSignOutAlert = true
                        }
                    )
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.backgroundSecondary)
                )
            }
        }
        .padding(.top, 20)
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.backgroundPrimary.ignoresSafeArea())
        .signOutAlert(isPresented: $showingSignOutAlert) {
            authVM.logout()
        }
        .sheet(isPresented: $showEditNameSheet) {
            EditFullNameView(settingsVM: settingsVM)
        }
        .sheet(isPresented: $showEditProfilePictureSheet) {
            EditProfilePictureView()
        }
        .onAppear {
            guard let user = authVM.authState.currentUser else { return }
            settingsVM.setup(user: user)
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .environmentObject(AuthViewModel(firebaseService: FirebaseService()))
    }
}
