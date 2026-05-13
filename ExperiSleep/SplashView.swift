import SwiftUI

struct SplashView: View {
    var onFinished: () -> Void

    let cyan = Color(red: 0.0, green: 0.90, blue: 0.80)

    @State private var logoScale: CGFloat = 0.7
    @State private var logoOpacity: Double = 0
    @State private var textOpacity: Double = 0
    @State private var taglineOpacity: Double = 0
    @State private var gesamtOpacity: Double = 1

    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.11, blue: 0.24)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .cornerRadius(24)
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)

                HStack(spacing: 0) {
                    Text("Experi")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                    Text("Sleep")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(cyan)
                }
                .opacity(textOpacity)

                Text("Finde was deinen Schlaf verbessert.")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.5))
                    .opacity(taglineOpacity)
            }
        }
        .opacity(gesamtOpacity)
        .onAppear { animieren() }
    }

    func animieren() {
        // Logo einblenden
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            logoScale = 1.0
            logoOpacity = 1
        }

        // Text einblenden
        withAnimation(.easeOut(duration: 0.5).delay(0.4)) {
            textOpacity = 1
        }

        // Tagline einblenden
        withAnimation(.easeOut(duration: 0.5).delay(0.7)) {
            taglineOpacity = 1
        }

        // Ausblenden und zur App wechseln
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            withAnimation(.easeInOut(duration: 0.4)) {
                gesamtOpacity = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                onFinished()
            }
        }
    }
}
