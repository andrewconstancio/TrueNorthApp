//
//  String.swift
//  true-north-app
//
//  Created by Andrew Constancio on 7/15/25.
//
import SwiftUI

extension String {
    /// Converts a hex color string (e.g. "#FF5733" or "FF5733") to an Int (e.g. 0xFF5733).
    var hexToInt: Int? {
        let cleaned = self.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        return Int(cleaned, radix: 16)
    }
}
