import SwiftUI

struct GoalFormData {
    var name: String = ""
    var description: String = ""
    var category: String = "Personal"
    var startDate: Date = Date()
    var endDate: Date = Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date()
    var isEndless: Bool = false
    var selectedColor: Color = .blue
    
    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
