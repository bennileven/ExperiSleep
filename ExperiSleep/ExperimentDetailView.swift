import SwiftUI

struct ExperimentDetailView: View {
    var titel: String
    var icon: String
    var color: Color
    
    @EnvironmentObject private var aktiveExperimente: AktiveExperimente
    @EnvironmentObject private var speicher: CheckInSpeicher
    @EnvironmentObject var theme: AppTheme
    @State private var zeigeKonfliktAlert = false
    @State private var baselineGeladen = false
    @State private var healthKitLaedt = false
    @AppStorage("baselineSchlaf") var baselineSchlaf = 5.0
    
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
            theme.hintergrund
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    iconTitelBereich
                    erklaerungBereich
                    VStack(spacing: 12) {
                        if !istAktiv && speicher.eintraege.isEmpty {
                            baselineAusHealthKitButton
                        }
                        startenStoppenButton
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
                .foregroundColor(.primary)
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
        .background(theme.karte)
        .cornerRadius(14)
        .padding(.horizontal)
    }
    
    var startenStoppenButton: some View {
        Button(action: {
            if istAktiv {
                HapticManager.warning()
                aktiveExperimente.stoppen(titel: titel)
            } else if !aktiveExperimente.aktive.isEmpty {
                HapticManager.impact(.rigid)
                zeigeKonfliktAlert = true
            } else {
                HapticManager.impact(.heavy)
                aktiveExperimente.starten(titel: titel)
                let letzten14 = speicher.eintraege
                    .sorted { $0.datum > $1.datum }
                    .prefix(14)
                if !letzten14.isEmpty {
                    let summe = letzten14.reduce(0) { $0 + $1.schlafqualitaet }
                    baselineSchlaf = Double(summe) / Double(letzten14.count)
                }
            }
        }) {
            HStack {
                Image(systemName: istAktiv ? "stop.circle.fill" : "play.circle.fill")
                Text(istAktiv ? "Experiment stoppen" : "Experiment starten")
                    .font(.headline)
            }
            .foregroundColor(.primary)
            .frame(maxWidth: .infinity)
            .padding()
            .background(istAktiv ? Color.red.opacity(0.7) : color)
            .cornerRadius(14)
        }
        .padding(.horizontal)
    }
    
    var baselineAusHealthKitButton: some View {
        Button(action: {
            healthKitLaedt = true
            HealthKitManager.shared.berechtigungAnfragen { _ in
                HealthKitManager.shared.schlafdurchschnittLetzteNaechte(anzahl: 14) { durchschnitt in
                    healthKitLaedt = false
                    if let wert = durchschnitt {
                        baselineSchlaf = wert
                        baselineGeladen = true
                    }
                }
            }
        }) {
            HStack(spacing: 12) {
                if healthKitLaedt {
                    ProgressView().tint(.indigo)
                } else {
                    Image(systemName: baselineGeladen ? "checkmark.circle.fill" : "heart.fill")
                        .foregroundColor(baselineGeladen ? .green : .indigo)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(baselineGeladen ? "Ausgangswert geladen ✓" : "Ausgangswert aus Apple Health laden")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    Text(baselineGeladen
                        ? "Ø \(String(format: "%.1f", baselineSchlaf)) · letzte 14 Nächte"
                        : "Letzte 14 Nächte als Ausgangswert verwenden")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(baselineGeladen ? Color.green.opacity(0.12) : Color.indigo.opacity(0.12))
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(baselineGeladen ? Color.green.opacity(0.3) : Color.indigo.opacity(0.3), lineWidth: 1)
            )
        }
        .padding(.horizontal)
        .disabled(baselineGeladen || healthKitLaedt)
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
            .foregroundColor(.primary)
            .frame(maxWidth: .infinity)
            .padding()
            .background(theme.karte)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.primary.opacity(0.1), lineWidth: 1)
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
                .foregroundColor(.secondary)
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
