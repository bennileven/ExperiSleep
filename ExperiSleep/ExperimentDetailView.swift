import SwiftUI

struct ExperimentDetailView: View {
    var titel: String
    var icon: String
    var color: Color
    
    @EnvironmentObject private var aktiveExperimente: AktiveExperimente
    @EnvironmentObject private var speicher: CheckInSpeicher
    @State private var importiert = false
    @State private var importiertAnzahl = 0
    @State private var demoAktiv = false
    
    var istAktiv: Bool {
        aktiveExperimente.istAktiv(titel: titel)
    }
    
    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.11, blue: 0.24)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    
                    // Icon & Titel
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
                                Text("Experiment läuft")
                                    .font(.caption)
                                    .foregroundColor(.green)
                                
                                if let start = aktiveExperimente.startDatum(fuer: titel) {
                                    let tage = Calendar.current.dateComponents([.day], from: start, to: Date()).day ?? 0
                                    Text("· Tag \(tage + 1) von 14")
                                        .font(.caption)
                                        .foregroundColor(.green.opacity(0.7))
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.green.opacity(0.15))
                            .cornerRadius(20)
                        }
                    }
                    .padding(.top, 20)
                    
                    // Erklärung
                    VStack(alignment: .leading, spacing: 15) {
                        InfoRow(icon: "1.circle.fill",
                                text: "Dein Ausgangswert wurde beim Onboarding erfasst")
                        InfoRow(icon: "2.circle.fill",
                                text: "Mache täglich einen Check-in — Apple Health füllt die Schlafdaten automatisch aus")
                        InfoRow(icon: "chart.bar.fill",
                                text: "Nach 14 Tagen siehst du ob das Experiment geholfen hat")
                    }
                    .padding()
                    .background(Color.white.opacity(0.06))
                    .cornerRadius(14)
                    .padding(.horizontal)
                    
                    // Buttons
                    VStack(spacing: 12) {
                        
                        // Starten / Stoppen
                        Button(action: {
                            if istAktiv {
                                aktiveExperimente.stoppen(titel: titel)
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
                        
                        if istAktiv {
                            
                            // Apple Health Import
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
                            
                            // Demo Modus Toggle
                            Button(action: {
                                if demoAktiv {
                                    // Demo Daten entfernen
                                    speicher.eintraege.removeAll {
                                        $0.experimentTitel == titel && $0.energie == 5 && $0.stress <= 7
                                    }
                                    demoAktiv = false
                                } else {
                                    // Demo Daten laden
                                    let basisDatum = Calendar.current.date(byAdding: .day, value: -13, to: Date())!
                                    let demoDaten: [(Int, Int, Int)] = [
                                        (5, 5, 6), (4, 5, 7), (6, 5, 5), (5, 6, 6), (4, 4, 7),
                                        (5, 5, 6), (7, 6, 4), (8, 7, 3), (7, 7, 4), (8, 8, 3),
                                        (9, 7, 3), (8, 8, 2), (9, 8, 3), (8, 7, 3)
                                    ]
                                    
                                    for (index, (schlaf, energie, stress)) in demoDaten.enumerated() {
                                        guard let datum = Calendar.current.date(byAdding: .day, value: index, to: basisDatum) else { continue }
                                        let zielTag = Calendar.current.startOfDay(for: datum)
                                        
                                        let existiert = speicher.eintraege.contains {
                                            Calendar.current.startOfDay(for: $0.datum) == zielTag
                                        }
                                        if existiert { continue }
                                        
                                        let eintrag = CheckInEintrag(
                                            datum: zielTag.addingTimeInterval(8 * 3600),
                                            schlafqualitaet: schlaf,
                                            energie: energie,
                                            stress: stress,
                                            experimentTitel: titel,
                                            istBaseline: false
                                        )
                                        speicher.speichern(eintrag: eintrag)
                                    }
                                    demoAktiv = true
                                }
                            }) {
                                HStack {
                                    Image(systemName: demoAktiv ? "eye.slash.fill" : "wand.and.stars")
                                        .foregroundColor(.purple)
                                    Text(demoAktiv ? "Demo Modus deaktivieren" : "Demo Modus aktivieren")
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                    Spacer()
                                    
                                    // Toggle Indikator
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
                        
                        // Auswertung
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
            }
        }
        .navigationTitle("Experiment")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
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
