import SwiftUI

/// Sheet view for editing the user's first and last name.
///
/// Validates input to ensure both fields are non-empty before allowing save.
/// Updates both fields in a single Firebase call for efficiency.
///
struct EditFullNameView: View {
    /// Auth view model for updating user data.
    @EnvironmentObject var authVM: AuthViewModel
    
    /// Settings view model containing the name fields being edited.
    @ObservedObject var settingsVM: SettingsViewModel
    
    /// Environment value to dismiss the sheet.
    @Environment(\.dismiss) private var dismiss
    
    /// Focus state for automatically showing keyboard on appear.
    @FocusState private var isKeyboardFocused: Bool
    
    /// Validates that both first and last names are non-empty after trimming.
    ///
    /// - Returns: `true` if both names are valid, `false` otherwise.
    ///
    private var isValid: Bool {
        !settingsVM.firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !settingsVM.lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
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
            
            Button {
                guard isValid else { return }
                
                Task {
                    // Single Firebase call to update both fields at once
                    await authVM.updateUserFields([
                        "firstName": settingsVM.firstName.trimmingCharacters(in: .whitespacesAndNewlines),
                        "lastName": settingsVM.lastName.trimmingCharacters(in: .whitespacesAndNewlines)
                    ])
                    
                    // Dismiss sheet after successful update
                    dismiss()
                }
            } label: {
                Text("Save")
                    .font(FontManager.Bungee.regular.font(size: 18))
                    .foregroundStyle(.textPrimary)
                    .frame(width: 340, height: 65)
                    .background(isValid ? Color.sunglow.opacity(0.8) : Color.gray.opacity(0.5))
                    .clipShape(Capsule())
                    .padding()
            }
            .disabled(!isValid)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(Color.backgroundPrimary)
        .onAppear {
            isKeyboardFocused = true
        }
    }
}

