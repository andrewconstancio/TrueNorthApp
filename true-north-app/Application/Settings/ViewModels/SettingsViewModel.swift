import SwiftUI

/// View model for managing user profile settings data.
///
/// This view model holds temporary values for editing user profile information
/// before saving changes to Firebase.
///
class SettingsViewModel: ObservableObject {
    /// The user's first name (editable).
    @Published var firstName = ""
    
    /// The user's last name (editable).
    @Published var lastName = ""
     
    /// Initializes the view model with current user data.
    ///
    /// - Parameter user: The current user whose data will be loaded.
    ///
    func setup(user: User) {
        self.firstName = user.firstName
        self.lastName = user.lastName
    }
}
