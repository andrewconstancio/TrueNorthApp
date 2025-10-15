import SwiftUI

/// A helper method for this apps fonts.
struct FontManager {
    /// Banger fonts.
    enum Banger: String {
        /// Regular.
        case regular = "Bangers-Regular"
        
        /// Returns a custom SwiftUI font for this Nunito helper.
        /// - Parameter size: Size of the font.
        /// - Returns: A custom font.
        func font(size: CGFloat) -> Font {
            return .custom(self.rawValue, size: size)
        }
    }
    
    /// Bungee fonts.
    enum Bungee: String {
        /// Regular.
        case regular = "Bungee-Regular"
        
        /// Returns a custom SwiftUI font for this Nunito helper.
        /// - Parameter size: Size of the font.
        /// - Returns: A custom font.
        func font(size: CGFloat) -> Font {
            return .custom(self.rawValue, size: size)
        }
    }
}
