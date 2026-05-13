import SwiftUI

struct StreakMeilensteinView: View {
    var tage: Int
    var onDismiss: () -> Void

    let cyan = Color(red: 0.0, green: 0.90, blue: 0.80)

    @State private var karteScale: CGFloat = 0.5
    @State private var karteOpacity: Double = 0
    @State private var partikelSichtbar = false

    var emoji: String { tage >= 14 ? "🏆" : "🔥" }
    var titel: String { tage >= 14 ? "14-Tage-Streak!" : "7-Tage-Streak!" }
    var beschreibung: String {
        tage >= 14
            ? "Unglaublich! Zwei Wochen am Stück — du hast Schlaf-Disziplin bewiesen. Deine Daten sind jetzt aussagekräftig genug für eine echte Auswertung."
            : "Eine ganze Woche ohne Pause! Du bist auf dem besten Weg, herauszufinden was deinen Schlaf wirklich verbessert."
    }

    let partikelFarben: [Color] = [.cyan, .green, .yellow, .orange, .pink, .purple]

    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture { abbrechen() }

            // Partikel
            if partikelSichtbar {
                ForEach(0..<20, id: \.self) { i in
                    Partikel(farbe: partikelFarben[i % partikelFarben.count], index: i)
                }
            }

            // Karte
            VStack(spacing: 24) {
                Text(emoji)
                    .font(.system(size: 72))

                VStack(spacing: 10) {
                    Text(titel)
                        .font(.title)
                        .bold()
                        .foregroundColor(.white)

                    Text("\(tage) Tage in Folge")
                        .font(.subheadline)
                        .foregroundColor(cyan)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(cyan.opacity(0.15))
                        .cornerRadius(20)
                }

                Text(beschreibung)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.75))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 8)

                Button(action: abbrechen) {
                    Text("Weiter so! 💪")
                        .font(.headline)
                        .foregroundColor(Color(red: 0.05, green: 0.11, blue: 0.24))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(cyan)
                        .cornerRadius(14)
                }
            }
            .padding(28)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(red: 0.08, green: 0.14, blue: 0.28))
            )
            .padding(.horizontal, 32)
            .scaleEffect(karteScale)
            .opacity(karteOpacity)
        }
        .onAppear {
            HapticManager.success()
            withAnimation(.spring(response: 0.5, dampingFraction: 0.65)) {
                karteScale = 1.0
                karteOpacity = 1.0
            }
            withAnimation(.easeOut(duration: 0.3).delay(0.2)) {
                partikelSichtbar = true
            }
        }
    }

    func abbrechen() {
        HapticManager.soft()
        withAnimation(.easeIn(duration: 0.2)) {
            karteScale = 0.9
            karteOpacity = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { onDismiss() }
    }
}

struct Partikel: View {
    var farbe: Color
    var index: Int

    @State private var offsetY: CGFloat = 0
    @State private var offsetX: CGFloat = 0
    @State private var opacity: Double = 1

    var body: some View {
        Circle()
            .fill(farbe)
            .frame(width: CGFloat.random(in: 6...12), height: CGFloat.random(in: 6...12))
            .offset(x: offsetX, y: offsetY)
            .opacity(opacity)
            .onAppear {
                let angle = Double(index) / 20.0 * 2 * .pi
                let radius = CGFloat.random(in: 80...180)
                withAnimation(.easeOut(duration: Double.random(in: 0.8...1.4))) {
                    offsetX = cos(angle) * radius
                    offsetY = sin(angle) * radius - 60
                    opacity = 0
                }
            }
    }
}
