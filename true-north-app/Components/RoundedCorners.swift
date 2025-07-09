//
//  RoundedCorners.swift
//  true-north-app
//
//  Created by Andrew Constancio on 7/7/25.
//

import SwiftUI

struct RoundedCorners: Shape {
    var radius: CGFloat = 8.0
    var corners: UIRectCorner = [.topLeft, .topRight]

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
