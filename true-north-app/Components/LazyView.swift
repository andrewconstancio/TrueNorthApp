//
//  LazyView.swift
//  true-north-app
//
//  Created by Andrew Constancio on 7/8/25.
//

import SwiftUI

struct LazyView<Content: View>: View {
    let build: () -> Content

    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }

    var body: some View {
        build()
    }
}
