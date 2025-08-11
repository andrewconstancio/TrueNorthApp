import SwiftUI
import Lottie

struct SplashView: View {
    var body: some View {
        VStack {
            LottieView(animation: .named("Confetti"))
                .playbackMode(.playing(.toProgress(1, loopMode: .playOnce)))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.backgroundPrimary)
    }
}

#Preview {
    SplashView()
}
