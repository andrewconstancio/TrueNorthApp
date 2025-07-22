import Foundation

enum TNError: Error, LocalizedError {
    case generalError
    
    var errorDescription: String? {
        switch self {
        case .generalError:
            return "Oops! Something went wrong."
        }
    }
}
