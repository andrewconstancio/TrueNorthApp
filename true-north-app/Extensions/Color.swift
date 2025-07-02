//
//  Color.swift
//  true-north-app
//
//  Created by Andrew Constancio on 6/24/25.
//
import Foundation
import UIKit
import SwiftUI

extension Color {
    static var themeColor: Color {
        return Color.indigo
    }
}

extension Color {
    init(hex: Int, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: opacity
        )
    }
}
