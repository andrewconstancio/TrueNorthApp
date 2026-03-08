import SwiftUI

/// Extensions of the view.
extension View {
    /// A general purpose alert.
    func generalAlert(
        title: String,
        message: String? = nil,
        isPresented: Binding<Bool>,
        primaryButton: (title: String, role: ButtonRole?, action: () -> Void)? = nil,
        secondaryButton: (title: String, role: ButtonRole?, action: () -> Void)? = nil
    ) -> some View {
        alert(title, isPresented: isPresented, actions: {
            if let primary = primaryButton {
                Button(primary.title, role: primary.role, action: primary.action)
            }
            if let secondary = secondaryButton {
                Button(secondary.title, role: secondary.role, action: secondary.action)
            }
            if primaryButton == nil && secondaryButton == nil {
                Button("OK", role: .cancel) {}
            }
        }, message: {
            if let message = message {
                Text(message)
            }
        })
    }
    
    /// Hides the keyboard when the screen is tapped.
    func hideKeyboardOnTap() -> some View {
        self.onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                            to: nil, from: nil, for: nil)
        }
    }
    
    /// The sign out alert.
    func signOutAlert(
        isPresented: Binding<Bool>,
        onConfirm: @escaping () -> Void
    ) -> some View {
        alert("Sign Out", isPresented: isPresented, actions: {
            Button("Cancel", role: .cancel) {}
            Button("Sign Out", role: .destructive, action: onConfirm)
        }, message: {
            Text("Are you sure you want to sign out?")
        })
    }

    /// The error alert.
    func errorAlert(
        isPresented: Binding<Bool>,
        error: AppError?
    ) -> some View {
        alert(isPresented: isPresented, error: error, actions: { _ in
            Button("OK", role: .cancel) {}
        }, message: { error in
            VStack(alignment: .leading, spacing: 4) {
                if let description = error.errorDescription {
                    Text(description)
                }
                if let suggestion = error.recoverySuggestion {
                    Text(suggestion)
                }
            }
        })
    }
}
