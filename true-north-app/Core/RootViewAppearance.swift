//
//  RootViewAppearance.swift
//  true-north-app
//
//  Created by Andrew Constancio on 6/24/25.
//

import SwiftUI
import Combine

// MARK: - RootViewAppearance

struct RootViewAppearance: ViewModifier {
    
    @Environment(\.dismiss) private var dismiss

    func body(content: Content) -> some View {
//        ZStack {
//            Color(hex: 0x1c1c1c)
//                .ignoresSafeArea() // Fills the entire screen

            content
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            dismiss()
                        }) {
                            HStack {
                                Image(systemName: "chevron.left")
                                    .bold()
                            }
                            .foregroundColor(.primary)
                        }
                    }
                }
//        }
    }
}
