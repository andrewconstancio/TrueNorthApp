import SwiftUI

class SettingsViewModel: ObservableObject {
    @Published var firstName = ""
    @Published var lastName = ""
     
    func setup(user: User) {
        self.firstName = user.firstName
        self.lastName = user.lastName
    }
}

struct SettingsView: View {
    /// Auth view model.
    @EnvironmentObject var authVM: AuthViewModel
    
    @StateObject private var settingsVM = SettingsViewModel()
    
    /// Show the sign out alert.
    @State private var showingSignOutAlert = false
    
    @State private var showEditNameSheet = false
    
    var body: some View {
        VStack {
            titleView
            ScrollView {
                VStack(spacing: 22) {
                    SettingsRow(
                        title: "Change name",
                        icon: "tag.fill",
                        action: {
                            showEditNameSheet = true
                        }
                    )
                    
                    SettingsRow(
                        title: "Change profile picture",
                        icon: "person.fill",
                        action: {
                            showingSignOutAlert = true
                        }
                    )
                    
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
        .onAppear {
            guard let user = authVM.authState.currentUser else { return }
            settingsVM.setup(user: user)
        }
    }
    
    /// Title.
    private var titleView: some View {
        Text("Settings")
            .foregroundStyle(.textSecondary)
            .font(FontManager.Bungee.regular.font(size: 16))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 16)
    }
}

struct SettingsRow: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Circle()
                    .fill(Color.backgroundLighter)
                    .frame(width: 36, height: 36)
                    .overlay(
                        Image(systemName: icon)
                            .foregroundStyle(.textSecondary)
                    )
                
                Text(title)
                    .foregroundStyle(.textPrimary)
                    .font(FontManager.Bungee.regular.font(size: 16))
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundStyle(.textSecondary)
                    .fontWeight(.bold)
            }
          
        }
    }
}

struct EditFullNameView: View {
    
    @ObservedObject var settingsVM: SettingsViewModel
    
    @FocusState private var isKeyboardFocused: Bool
    
    var body: some View {
        VStack {
            Text("Edit your name")
                .font(FontManager.Bungee.regular.font(size: 22))
                .foregroundStyle(.textPrimary)
            
            // First name
            CustomInputField(
                imageName: nil,
                placeholderText: "First Name",
                keyboardType: .default,
                text: $settingsVM.firstName
            )
            .focused($isKeyboardFocused)
            
            // Last name
            CustomInputField(
                imageName: nil,
                placeholderText: "Last Name",
                keyboardType: .default,
                text: $settingsVM.lastName
            )
            
            Text("Save")
                .font(FontManager.Bungee.regular.font(size: 18))
                .foregroundStyle(.textPrimary)
                .frame(width: 340, height: 65)
                .background(Color.sunglow.opacity(0.8))
                .clipShape(Capsule())
                .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(Color.backgroundPrimary)
        .onAppear {
            isKeyboardFocused = true
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .environmentObject(AuthViewModel(firebaseService: FirebaseService()))
    }
}
