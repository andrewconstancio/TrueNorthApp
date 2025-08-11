import SwiftUI

struct AddProfilePictureView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var shouldShowImagePicker = false
    @State private var lastScaleValue: CGFloat = 1.0
    @State private var scale: CGFloat = 1.0
    
    private var isValidProfilePicture: Bool {
        guard let _ = viewModel.profileSetup.profileImage else {
            return false
        }
        return true
    }

    var body: some View {
        VStack {
            Spacer()

            Text("Add a profile picture")
                .font(FontManager.Bungee.regular.font(size: 18))
                .foregroundStyle(.textPrimary)
                .padding(.bottom, 20)

            Button {
                shouldShowImagePicker.toggle()
            } label: {
                ProfileImageView(
                    image: viewModel.profileSetup.profileImage,
                    scale: $scale,
                    lastScaleValue: $lastScaleValue
                )
            }

            Spacer()

            Button {
                Task {
                    await viewModel.saveUserProfile()
                }
            } label: {
                Text("Submit")
                    .font(FontManager.Bungee.regular.font(size: 22))
                    .foregroundStyle(.textPrimary)
                    .frame(width: 340, height: 65)
                    .background(isValidProfilePicture ? Color.themeColor : Color.black.opacity(0.4))
                    .clipShape(Capsule())
                    .opacity(isValidProfilePicture ? 1 : 0.5)
            }
            .padding(.bottom, 40)
        }
        .fullScreenCover(isPresented: $shouldShowImagePicker) {
            ImageMoveAndScaleSheet(croppedImage: $viewModel.profileSetup.profileImage)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.backgroundPrimary)
    }
}

#Preview {
    AddProfilePictureView()
}
