import Foundation

enum AppError: LocalizedError {
    case networkError(String)
    case dataParsingError
    case customError(message: String)

    var errorDescription: String? {
        switch self {
        case .networkError(let message):
            return "Network Error: \(message)"
        case .dataParsingError:
            return "Data Parsing Error"
        case .customError(let message):
            return message
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .networkError:
            return "Please check your internet connection and try again."
        case .dataParsingError:
            return "Please contact support if the issue persists."
        case .customError:
            return nil
        }
    }
}
