import SwiftUI

/// Sheet view for changing the user's profile picture.
///
/// Displays the current profile picture and allows the user to select
/// a new image using the ImageMoveAndScaleSheet for cropping and scaling.
///
struct EditProfilePictureView: View {
    
    /// Auth view model for saving the updated profile image.
    @EnvironmentObject var authVM: AuthViewModel
    
    /// Environment value to dismiss the sheet.
    @Environment(\.dismiss) private var dismiss
    
    /// Flag to show the image picker and crop sheet.
    @State private var showEditProfilePicture = false
    
    /// The newly selected and cropped profile image, waiting to be saved.
    @State private var updateProfileImage: UIImage?
    
    /// Flag for is loading uploading new photo. 
    @State private var isloading = false
    
    var body: some View {
        VStack {
            if updateProfileImage != nil {
                setProfileImageView
            } else  {
                initialProfileImageView
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(Color.backgroundPrimary)
        .fullScreenCover(isPresented: $showEditProfilePicture) {
            ImageMoveAndScaleSheet(croppedImage: $updateProfileImage)
        }
        .loadingOverlay(isLoading: isloading)
    }
    
    /// Initial view showing the current profile picture with a change button.
    @ViewBuilder
    private var initialProfileImageView: some View {
        if let user = authVM.authState.currentUser,
           let urlString = user.profileImageUrl,
           let url = URL(string: urlString) {
            AsyncCachedImage(url: url) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .clipShape(Circle())
                    .frame(width: 200, height: 200)
                    .overlay(
                       Circle()
                           .stroke(Color.sunglow, lineWidth: 3)
                    )
            } placeholder: {
                ProgressView()
            }
        }
        
        Button {
            showEditProfilePicture = true
        } label: {
            Text("Change")
                .font(FontManager.Bungee.regular.font(size: 18))
                .foregroundStyle(.textPrimary)
                .frame(width: 340, height: 65)
                .background(Color.sunglow.opacity(0.8))
                .clipShape(Capsule())
                .padding()
        }
    }
    
    /// View showing the newly selected image with a save button.
    @ViewBuilder
    private var setProfileImageView: some View {
        if let uid = authVM.authState.currentUser?.id, let image = updateProfileImage {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .clipShape(Circle())
                .frame(width: 200, height: 200)
                .overlay(
                   Circle()
                       .stroke(Color.sunglow, lineWidth: 3)
                )
            
            Button {
                print("save new image")
                Task {
                    isloading = true
                    await authVM.saveProfileImage(uid: uid, image: image, refreshUser: true)
                    dismiss()
                }
            } label: {
                Text("Save")
                    .font(FontManager.Bungee.regular.font(size: 18))
                    .foregroundStyle(.textPrimary)
                    .frame(width: 340, height: 65)
                    .background(Color.sunglow.opacity(0.8))
                    .clipShape(Capsule())
                    .padding()
            }
        }
    }
}
