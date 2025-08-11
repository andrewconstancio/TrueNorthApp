import SwiftUI

enum GoalCategories: String, CaseIterable {
    case fitness = "fitness", business = "business", personal = "personal", health = "health", education = "education"
    
    var icon: String {
        switch self {
        case .fitness:
            return "fitness-icon"
        case .business:
            return "business-icon"
        case .personal:
            return "personal-icon"
        case .health:
            return "health-icon"
        case .education:
            return "education-icon"
        }
    }
    
    var color: Color {
        switch self {
        case .fitness:
            return Color.blue
        case .business:
            return Color.black
        case .personal:
            return Color.orange
        case .health:
            return Color.pink
        case .education:
            return Color.green
        }
    }
}
