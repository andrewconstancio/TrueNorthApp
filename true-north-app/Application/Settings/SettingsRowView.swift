import SwiftUI

/// A reusable row component for settings menu options.
///
/// Displays a circular icon, title text, and chevron indicator.
/// Executes the provided action when tapped.
///
struct SettingsRow: View {
    /// The title text for the settings option.
    let title: String
    
    /// The SF Symbol name for the icon.
    let icon: String
    
    /// The action to execute when the row is tapped.
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
