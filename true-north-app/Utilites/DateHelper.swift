import Foundation

struct DateHelper {
    static var formattedCurrentDate: String {
        let currentDate = Date()
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: currentDate)
    }
}
