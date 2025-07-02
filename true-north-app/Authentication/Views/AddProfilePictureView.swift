//
//  AddProfilePictureView.swift
//  true-north-app
//
//  Created by Andrew Constancio on 6/30/25.
//

import SwiftUI

struct AddProfilePictureView: View {
    @State private var shouldShowImagePicker = false
    @State private var profilePicture: UIImage?
    @State private var lastScaleValue: CGFloat = 1.0
    @State private var scale: CGFloat = 1.0
    
    private var isValidProfilePicture: Bool {
        guard let _ = profilePicture else {
            return false
        }
        return true
    }

    var body: some View {
        VStack {
            Spacer()

            Text("Add a profile picture")
                .font(.title)
                .fontWeight(.bold)
                .padding(.bottom, 20)

            Button {
                shouldShowImagePicker.toggle()
            } label: {
                ProfileImageView(
                    image: profilePicture,
                    scale: $scale,
                    lastScaleValue: $lastScaleValue
                )
            }

            Spacer()

            Button {
                // Handle continue action
            } label: {
                Text("Continue")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 340, height: 65)
                    .background(isValidProfilePicture ? Color.themeColor : Color.black.opacity(0.4))
                    .clipShape(Capsule())
                    .opacity(isValidProfilePicture ? 1 : 0.5)
            }
            .padding(.bottom, 40)
        }
        .fullScreenCover(isPresented: $shouldShowImagePicker) {
            ImageMoveAndScaleSheet(croppedImage: $profilePicture)
        }
        .padding()
    }
}

#Preview {
    AddProfilePictureView()
}
