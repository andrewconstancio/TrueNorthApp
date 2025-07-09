//
//  LoadingView.swift
//  true-north-app
//
//  Created by Andrew Constancio on 7/9/25.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                ProgressView()
                    .scaleEffect(1.5)
                
                Text("Loading...")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
        }
    }
}
