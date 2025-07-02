//
//  TNError.swift
//  true-north-app
//
//  Created by Andrew Constancio on 6/26/25.
//
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
