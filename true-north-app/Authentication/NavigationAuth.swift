import SwiftUI

struct NavigationAuth: ViewModifier {
    @Binding var path: NavigationPath
    
    func body(content: Content) -> some View {
        content
            .navigationDestination(for: AuthRoute.self) { route in
                switch route {
                case .addProfilePicture:
                    AddProfilePictureView()
                case .addFullName:
                    AddFullNameView()
                }
            }
    }
}
