/// ViewModifier for styling form sections with padding, background, and corner radius
struct FormSection: ViewModifier {
    var tintColor: Color
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(
              ZStack {
                  RoundedRectangle(cornerRadius: 12, style: .continuous)
                      .fill(.ultraThinMaterial) // Adds a blurred, translucent material effect
              }
            )
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
