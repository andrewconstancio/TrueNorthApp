import SwiftUI

/// ViewModifier for styling form sections with padding, background, and corner radius
struct FormSection: ViewModifier {
    var tintColor: Color
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
              ZStack {
                  RoundedRectangle(cornerRadius: 12, style: .continuous)
                      .fill(.black.opacity(0.1))
              }
            )
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
