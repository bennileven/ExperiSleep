import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var theme: AppTheme
    @AppStorage("onboardingAbgeschlossen") var onboardingAbgeschlossen = false
    @AppStorage("baselineEnergie") var baselineEnergie = 5.0
    @AppStorage("baselineStress") var baselineStress = 5.0
    @AppStorage("nutzername") var nutzername = ""

    @State private var schritt = 0
    @State private var nameEingabe = ""
    let cyan = Color(red: 0.0, green: 0.90, blue: 0.80)

    var weiterDeaktiviert: Bool {
        schritt == 1 && nameEingabe.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var body: some View {
        ZStack {
            theme.hintergrund
                .ignoresSafeArea()

            GlassEffectContainer {
            VStack(spacing: 30) {

                // Zurück + Fortschritt
                HStack(spacing: 12) {
                    Button(action: {
                        withAnimation { schritt -= 1 }
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.primary)
                            .padding(8)
                            .glassEffect(in: Circle())
                    }
                    .opacity(schritt > 0 ? 1 : 0)
                    .disabled(schritt == 0)

                    HStack(spacing: 8) {
                        ForEach(0..<4) { i in
                            RoundedRectangle(cornerRadius: 4)
                                .fill(i <= schritt ? cyan : Color.primary.opacity(0.15))
                                .frame(height: 4)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                Spacer()
                
                // Schritte
                if schritt == 0 {
                    WillkommensSchritt(cyan: cyan)
                } else if schritt == 1 {
                    BenutzerNameSchritt(nameEingabe: $nameEingabe, cyan: cyan)
                } else if schritt == 2 {
                    FrageSchritt(
                        frage: "Wie ist deine Energie morgens?",
                        beschreibung: "Wie fit fühlst du dich beim Aufwachen?",
                        icon: "bolt.fill",
                        color: .orange,
                        linksLabel: "Völlig erschöpft",
                        rechtsLabel: "Topfit",
                        wert: $baselineEnergie
                    )
                } else if schritt == 3 {
                    FrageSchritt(
                        frage: "Wie gestresst bist du?",
                        beschreibung: "Dein allgemeines Stresslevel",
                        icon: "brain.head.profile",
                        color: .red,
                        linksLabel: "Sehr entspannt",
                        rechtsLabel: "Sehr gestresst",
                        wert: $baselineStress
                    )
                }
                
                Spacer()
                
                // Button
                Button(action: {
                    if schritt == 1 {
                        nutzername = nameEingabe.trimmingCharacters(in: .whitespaces)
                        HapticManager.impact()
                        withAnimation { schritt += 1 }
                    } else if schritt < 3 {
                        HapticManager.soft()
                        withAnimation { schritt += 1 }
                    } else {
                        HapticManager.success()
                        onboardingAbgeschlossen = true
                    }
                }) {
                    Text(schritt == 0 ? "Loslegen" : schritt == 3 ? "Fertig" : "Weiter")
                        .font(.headline)
                        .foregroundColor(weiterDeaktiviert ? .secondary : theme.hintergrund)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(weiterDeaktiviert ? Color.primary.opacity(0.1) : cyan)
                        .cornerRadius(14)
                        .animation(.easeInOut(duration: 0.2), value: weiterDeaktiviert)
                }
                .disabled(weiterDeaktiviert)
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
            } // GlassEffectContainer
        }
    }
}

struct WillkommensSchritt: View {
    let cyan: Color
    
    var body: some View {
        VStack(spacing: 20) {
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .cornerRadius(26)
            
            Text("Willkommen bei ExperiSleep")
                .font(.title2)
                .bold()
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
            
            Text("Finde in 2 Wochen heraus was deinen Schlaf wirklich verbessert — mit persönlichen Experimenten und echten Daten.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 14) {
                OnboardingInfoRow(icon: "1.circle.fill", text: "Beantworte 3 kurze Fragen zu deinem Schlaf", color: cyan)
                OnboardingInfoRow(icon: "2.circle.fill", text: "Starte ein Experiment das dich interessiert", color: cyan)
                OnboardingInfoRow(icon: "3.circle.fill", text: "Mache täglich einen kurzen Check-in", color: cyan)
                OnboardingInfoRow(icon: "chart.bar.fill", text: "Sieh nach 2 Wochen ob es geholfen hat", color: cyan)
            }
            .padding()
            .glassEffect(in: RoundedRectangle(cornerRadius: 14))
            .padding(.horizontal)
        }
    }
}

struct BenutzerNameSchritt: View {
    @Binding var nameEingabe: String
    let cyan: Color
    @FocusState private var fokussiert: Bool

    var body: some View {
        VStack(spacing: 28) {
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(cyan)

            VStack(spacing: 10) {
                Text("Wie heißt du?")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)

                Text("Dein Name erscheint in der Community-Rangliste. Du kannst ihn jederzeit im Profil ändern.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            VStack(spacing: 8) {
                TextField("z.B. SleepHero99", text: $nameEingabe)
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .padding()
                    .glassEffect(in: RoundedRectangle(cornerRadius: 14))
                    .focused($fokussiert)
                    .onAppear { fokussiert = true }
                    .submitLabel(.done)

                if !nameEingabe.isEmpty {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                        Text("Hallo, \(nameEingabe)! 👋")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .transition(.opacity.combined(with: .scale))
                }
            }
            .padding(.horizontal)
            .animation(.easeInOut, value: nameEingabe.isEmpty)
        }
    }
}

struct FrageSchritt: View {
    var frage: String
    var beschreibung: String
    var icon: String
    var color: Color
    var linksLabel: String
    var rechtsLabel: String
    @Binding var wert: Double
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: icon)
                .font(.system(size: 50))
                .foregroundColor(color)
            
            VStack(spacing: 8) {
                Text(frage)
                    .font(.title2)
                    .bold()
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                Text(beschreibung)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            
            Text("\(Int(wert))")
                .font(.system(size: 80, weight: .bold))
                .foregroundColor(color)
            
            VStack(spacing: 8) {
                Slider(value: $wert, in: 1...10, step: 1)
                    .tint(color)
                    .padding(.horizontal)

                HStack {
                    Text(linksLabel)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(rechtsLabel)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
            }
            .padding()
            .glassEffect(in: RoundedRectangle(cornerRadius: 14))
            .padding(.horizontal)
        }
    }
}

struct OnboardingInfoRow: View {
    var icon: String
    var text: String
    var color: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
            Text(text)
                .font(.subheadline)
                .foregroundColor(.primary.opacity(0.8))
        }
    }
}

#Preview {
    OnboardingView()
}
