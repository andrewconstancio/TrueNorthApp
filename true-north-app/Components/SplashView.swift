import SwiftUI
import Lottie

struct SplashView: View {
    var body: some View {
        ZStack {
            AdaptiveView {
                Image("login_light")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 400, height: 400)
            } dark: {
                Image("login_dark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 400, height: 400)
            }
            
            LottieView(animation: .named("Confetti"))
                .playbackMode(.playing(.toProgress(1, loopMode: .playOnce)))
        }
    }
}

#Preview {
    SplashView()
}
