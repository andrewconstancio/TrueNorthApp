import SwiftUI

extension Date {
    var formattedDateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }
    
    func formatDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: self)
    }
    
    /// Check if a date is in the past.
    func isDateInPast() -> Bool {
        let calendar = Calendar.current
        let today = Date()
        return calendar.compare(self, to: today, toGranularity: .day) == .orderedAscending
    }
    
    /// Check if a date is in the future.
    func isDateInFuture() -> Bool {
        let calendar = Calendar.current
        let today = Date()
        return calendar.compare(self, to: today, toGranularity: .day) == .orderedDescending
    }
    
    /// Formats a date to be `yyyy-MM-dd` and returns a string. 
    func toYMDString() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0) // Optional: force UTC
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: self)
    }
}
