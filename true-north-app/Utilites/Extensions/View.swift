import SwiftUI

/// Extensions of the view.
extension View {
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
