import SwiftUI

struct ExperimentDetailView: View {
    var titel: String
    var icon: String
    var color: Color
    
    @EnvironmentObject private var aktiveExperimente: AktiveExperimente
    @EnvironmentObject private var speicher: CheckInSpeicher
    @State private var importiert = false
    @State private var importiertAnzahl = 0
    @State private var zeigeKonfliktAlert = false
    @AppStorage("demoModus") var demoAktiv = false
    
    var istAktiv: Bool {
        aktiveExperimente.istAktiv(titel: titel)
    }

    var konfliktNachricht: String {
        let name = aktiveExperimente.aktive.first?.titel ?? "ein anderes Experiment"
        return "Du machst gerade \u{201E}\(name)\u{201C}. Beende oder stoppe dieses Experiment zuerst, bevor du ein neues startest."
    }
    
    var tagAnzahl: Int {
        guard let start = aktiveExperimente.startDatum(fuer: titel) else { return 1 }
        return (Calendar.current.dateComponents([.day], from: start, to: Date()).day ?? 0) + 1
    }
    
    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.11, blue: 0.24)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    iconTitelBereich
                    erklaerungBereich
                    VStack(spacing: 12) {
                        startenStoppenButton
                        if istAktiv {
                            healthImportButton
                            demoModusButton
                        }
                        auswertungButton
                    }
                }
            }
        }
        .navigationTitle("Experiment")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .alert("Experiment bereits aktiv", isPresented: $zeigeKonfliktAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(konfliktNachricht)
        }
    }
    
    var iconTitelBereich: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(color)
            Text(titel)
                .font(.title2)
                .bold()
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            if istAktiv {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                    Text("Experiment läuft · Tag \(tagAnzahl) von 14")
                        .font(.caption)
                        .foregroundColor(.green)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.green.opacity(0.15))
                .cornerRadius(20)
            }
        }
        .padding(.top, 20)
    }
    
    var erklaerungBereich: some View {
        VStack(alignment: .leading, spacing: 15) {
            InfoRow(icon: "1.circle.fill", text: "Dein Ausgangswert wurde beim Onboarding erfasst")
            InfoRow(icon: "2.circle.fill", text: "Mache täglich einen Check-in — Apple Health füllt die Schlafdaten automatisch aus")
            InfoRow(icon: "chart.bar.fill", text: "Nach 14 Tagen siehst du ob das Experiment geholfen hat")
        }
        .padding()
        .background(Color.white.opacity(0.06))
        .cornerRadius(14)
        .padding(.horizontal)
    }
    
    var startenStoppenButton: some View {
        Button(action: {
            if istAktiv {
                aktiveExperimente.stoppen(titel: titel)
            } else if !aktiveExperimente.aktive.isEmpty {
                zeigeKonfliktAlert = true
            } else {
                aktiveExperimente.starten(titel: titel)
            }
        }) {
            HStack {
                Image(systemName: istAktiv ? "stop.circle.fill" : "play.circle.fill")
                Text(istAktiv ? "Experiment stoppen" : "Experiment starten")
                    .font(.headline)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(istAktiv ? Color.red.opacity(0.7) : color)
            .cornerRadius(14)
        }
        .padding(.horizontal)
    }
    
    var healthImportButton: some View {
        Button(action: {
            HealthKitManager.shared.vergangeneNaechteImportieren(
                anzahl: 4,
                experimentTitel: titel,
                speicher: speicher
            ) { anzahl in
                importiertAnzahl = anzahl
                importiert = true
            }
        }) {
            HStack {
                Image(systemName: importiert ? "checkmark.circle.fill" : "heart.fill")
                    .foregroundColor(importiert ? .green : .red)
                Text(importiert ? "\(importiertAnzahl) Nächte importiert ✓" : "Schlafdaten der letzten 4 Nächte importieren")
                    .font(.subheadline)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(importiert ? Color.green.opacity(0.15) : Color.red.opacity(0.15))
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(importiert ? Color.green.opacity(0.3) : Color.red.opacity(0.3), lineWidth: 1)
            )
        }
        .padding(.horizontal)
        .disabled(importiert)
    }
    
    var demoModusButton: some View {
        Button(action: { demoAktiv.toggle() }) {
            HStack {
                Image(systemName: demoAktiv ? "eye.slash.fill" : "wand.and.stars")
                    .foregroundColor(.purple)
                Text(demoAktiv ? "Demo Modus deaktivieren" : "Demo Modus aktivieren")
                    .font(.subheadline)
                    .foregroundColor(.white)
                Spacer()
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(demoAktiv ? Color.purple : Color.white.opacity(0.2))
                        .frame(width: 44, height: 26)
                    Circle()
                        .fill(.white)
                        .frame(width: 20, height: 20)
                        .offset(x: demoAktiv ? 9 : -9)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.purple.opacity(0.15))
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.purple.opacity(demoAktiv ? 0.6 : 0.3), lineWidth: 1)
            )
        }
        .padding(.horizontal)
    }
    
    var auswertungButton: some View {
        NavigationLink(destination: AuswertungView(
            experimentTitel: titel
        ).environmentObject(speicher)) {
            HStack {
                Image(systemName: "chart.bar.fill")
                Text("Auswertung ansehen")
                    .font(.headline)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.white.opacity(0.08))
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
        }
        .padding(.horizontal)
        .padding(.bottom, 30)
    }
}

struct InfoRow: View {
    var icon: String
    var text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.cyan)
            Text(text)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
        }
    }
}

#Preview {
    NavigationView {
        ExperimentDetailView(
            titel: "Kein Koffein nach 14 Uhr",
            icon: "cup.and.saucer.fill",
            color: .brown
        )
        .environmentObject(AktiveExperimente())
        .environmentObject(CheckInSpeicher())
    }
}
