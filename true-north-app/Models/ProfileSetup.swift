import SwiftUI

struct ProfileSetup {
    var firstName: String = ""
    var lastName: String = ""
    var profileImage: UIImage?
    
    var isValid: Bool {
        return !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               !lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               profileImage != nil
    }
}
