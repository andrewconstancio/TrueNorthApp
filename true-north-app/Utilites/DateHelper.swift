//
//  DateHelper.swift
//  true-north-app
//
//  Created by Andrew Constancio on 7/7/25.
//

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
