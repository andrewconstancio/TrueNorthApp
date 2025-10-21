import SwiftUI


/// View for full screen loading.
struct LoadingView: View {
    var body: some View {
      ZStack {
          // Blurred background
          Color.black.opacity(0.9) // Adjust opacity for desired blur intensity
              .ignoresSafeArea()
              .background(.ultraThinMaterial) // Applies a blur effect

          // Spinner
          ProgressView()
              .progressViewStyle(CircularProgressViewStyle(tint: .white))
              .scaleEffect(2) // Make the spinner larger
      }
      .opacity(0.7)
    }
}

/// Loading modifer to pass in a loading variable.
struct LoadingModifier: ViewModifier {
     var isLoading: Bool

     func body(content: Content) -> some View {
         ZStack {
             content
             if isLoading {
                 LoadingView()
                    .transition(.opacity.combined(with: .scale))
                    .animation(.easeOut(duration: 0.6), value: isLoading)
             }
         }
     }
 }

/// Extension fore the view.
 extension View {
     /// The loading overlay modifer.
     func loadingOverlay(isLoading: Bool) -> some View {
         self.modifier(LoadingModifier(isLoading: isLoading))
     }
 }

