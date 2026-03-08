import SwiftUI

struct CenterPopup<Content: View>: View {
    @Binding var isPresented: Bool
    let title: String?
    let backgroundColor: Color
    let content: Content

    init(
        isPresented: Binding<Bool>,
        title: String? = nil,
        backgroundColor: Color = .white,
        @ViewBuilder content: () -> Content
    ) {
        self._isPresented = isPresented
        self.title = title
        self.backgroundColor = backgroundColor
        self.content = content()
    }

    var body: some View {
        if isPresented {
            ZStack {
                // Dimmed background
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        dismiss()
                    }

                // Popup
                VStack(spacing: 16) {

                    // Header
                    HStack {
                        if let title {
                            Text(title)
                                .font(FontManager.Bungee.regular.font(size: 16))
                                .foregroundStyle(.textPrimary)
                        }

                        Spacer()

                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.textPrimary)
                                .padding(6)
                                .contentShape(Rectangle())
                        }
                    }

                    content
                }
                .padding()
                .background(backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(radius: 20)
                .padding(.horizontal, 24)
                .transition(.scale(scale: 0.9).combined(with: .opacity))
            }
            .animation(
                .spring(response: 0.35, dampingFraction: 0.85),
                value: isPresented
            )
        }
    }

    private func dismiss() {
        withAnimation {
            isPresented = false
        }
    }
}



#Preview {
    CenterPopup(isPresented: .constant(true), backgroundColor: .white) {
        VStack {
            Text("Testing hey")
        }
    }
}
