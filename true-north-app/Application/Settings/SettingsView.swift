import SwiftUI

struct SettingsView: View {
    /// Auth view model.
    @EnvironmentObject var authVM: AuthViewModel
    
    /// Show the sign out alert.
    @State private var showingSignOutAlert = false
    
    var body: some View {
        VStack {
            titleView
            ScrollView {
                VStack(spacing: 22) {
                    SettingsRow(
                        title: "Change name",
                        icon: "hand.wave.fill",
                        action: {
                            showingSignOutAlert = true
                        }
                    )
                    
                    SettingsRow(
                        title: "Change profile picture",
                        icon: "hand.wave.fill",
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
//                .background(
//                    RoundedRectangle(cornerRadius: 16)
//                        .fill(Color.backgroundLighter.opacity(0.7))
//                )
            }
        }
        .padding(.top, 20)
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.backgroundPrimary.ignoresSafeArea())
        .signOutAlert(isPresented: $showingSignOutAlert) {
            authVM.logout()
        }
    }
    
    /// Title.
    private var titleView: some View {
        HStack(alignment: .center) {
            Text("Settings")
                .foregroundStyle(.textSecondary)
                .font(FontManager.Bungee.regular.font(size: 16))
            Spacer()
        }
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

#Preview {
    NavigationView {
        SettingsView()
            .environmentObject(AuthViewModel())
    }
}
