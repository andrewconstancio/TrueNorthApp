//
//  ProfilePictureView.swift
//  true-north-app
//
//  Created by Andrew Constancio on 7/1/25.
//

import SwiftUI

struct ProfileImageView: View {
    var image: UIImage?
    @Binding var scale: CGFloat
    @Binding var lastScaleValue: CGFloat

    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 200, height: 200)
                    .clipShape(Circle())
                    .shadow(radius: 20)
                    .scaleEffect(scale)
                    .animation(.easeInOut(duration: 0.2), value: scale)
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                let delta = value / lastScaleValue
                                lastScaleValue = value
                                scale *= delta
                            }
                            .onEnded { _ in
                                lastScaleValue = 1.0
                            }
                    )
            } else {
                Image(systemName: "person.circle")
                    .foregroundStyle(Color.indigo)
                    .font(.system(size: 108))
                    .frame(width: 200, height: 200)
            }
        }
    }
}
