import SwiftUI

struct AuswertungView: View {
    var experimentTitel: String
    @EnvironmentObject private var speicher: CheckInSpeicher
    
    @AppStorage("baselineSchlaf") var baselineSchlaf = 5.0
    @AppStorage("baselineEnergie") var baselineEnergie = 5.0
    @AppStorage("baselineStress") var baselineStress = 5.0
    
    var baselineAvgSchlaf: Double { speicher.durchschnittSchlaf(experiment: experimentTitel, baseline: true) }
    var experimentAvgSchlaf: Double { speicher.durchschnittSchlaf(experiment: experimentTitel, baseline: false) }
    
    var verbesserungGegenOnboarding: Double {
        guard experimentAvgSchlaf > 0 else { return 0 }
        return experimentAvgSchlaf - baselineSchlaf
    }
    
    var verbesserungGegenBaseline: Double {
        guard baselineAvgSchlaf > 0 && experimentAvgSchlaf > 0 else { return 0 }
        return experimentAvgSchlaf - baselineAvgSchlaf
    }

    var tageSeitStart: Int {
        guard let erster = speicher.eintraegeFor(experiment: experimentTitel).map({ $0.datum }).min() else { return 0 }
        return Calendar.current.dateComponents([.day], from: erster, to: Date()).day ?? 0
    }

    var hatGenugDaten: Bool {
        speicher.eintraegeFor(experiment: experimentTitel).count >= 7
    }

    var experimentHatGeholfen: Bool {
        verbesserungGegenOnboarding > 0
    }
    
    var body: some View {
        let _ = print("Suche nach: '\(experimentTitel)' — Gefunden: \(speicher.eintraege.count) Einträge total, \(speicher.eintraegeFor(experiment: experimentTitel).count) für dieses Experiment")
        let _ = print("Alle Einträge: \(speicher.eintraege.map { $0.experimentTitel })")
        
        ZStack {
            Color(red: 0.05, green: 0.11, blue: 0.24)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: verbesserungGegenBaseline >= 0 ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(verbesserungGegenBaseline >= 0 ? .green : .red)
                        
                        Text("Auswertung")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.white)
                        
                        Text(experimentTitel)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .padding(.top, 20)
                    
                    // Schlaf Graph
                    SchlafGraphView(
                        eintraege: speicher.eintraegeFor(experiment: experimentTitel),
                        baselineWert: baselineSchlaf
                    )
                    
                    // Vergleich mit Ausgangswert
                    VStack(spacing: 16) {
                        Text("Vergleich mit deinem Ausgangswert")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.7))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack(spacing: 12) {
                            VergleichsKarte(
                                label: "Dein Start",
                                wert: baselineSchlaf,
                                farbe: .gray,
                                beschreibung: "Vor ExperiSleep"
                            )
                            VergleichsKarte(
                                label: "Jetzt",
                                wert: experimentAvgSchlaf > 0 ? experimentAvgSchlaf : baselineAvgSchlaf,
                                farbe: .indigo,
                                beschreibung: "Mit Experiment"
                            )
                            VergleichsKarte(
                                label: "Änderung",
                                wert: abs(verbesserungGegenOnboarding),
                                farbe: verbesserungGegenOnboarding >= 0 ? .green : .red,
                                beschreibung: verbesserungGegenOnboarding >= 0 ? "Besser" : "Schlechter",
                                istVeraenderung: true,
                                positiv: verbesserungGegenOnboarding >= 0
                            )
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.06))
                    .cornerRadius(14)
                    .padding(.horizontal)
                    
                    // Vorher Nachher Balken
                    VStack(spacing: 16) {
                        Text("Woche 1 vs Woche 2")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.7))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        BalkenRow(label: "Dein Ausgangswert", wert: baselineSchlaf, farbe: .gray.opacity(0.6))
                        BalkenRow(label: "Woche 1 (Normal)", wert: baselineAvgSchlaf, farbe: .gray)
                        BalkenRow(label: "Woche 2 (Experiment)", wert: experimentAvgSchlaf, farbe: .indigo)
                    }
                    .padding()
                    .background(Color.white.opacity(0.06))
                    .cornerRadius(14)
                    .padding(.horizontal)
                    
                    // Fazit
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Fazit")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text(fazitText())
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                            .lineSpacing(4)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white.opacity(0.06))
                    .cornerRadius(14)
                    .padding(.horizontal)
                    
                    // Statistiken
                    HStack(spacing: 12) {
                        StatKarte(
                            zahl: "\(speicher.eintraegeFor(experiment: experimentTitel).filter { $0.istBaseline }.count)",
                            label: "Baseline\nEinträge",
                            farbe: .gray
                        )
                        StatKarte(
                            zahl: "\(speicher.eintraegeFor(experiment: experimentTitel).filter { !$0.istBaseline }.count)",
                            label: "Experiment\nEinträge",
                            farbe: .indigo
                        )
                    }
                    .padding(.horizontal)

                    // Wissenschaftliche Analyse
                    if hatGenugDaten {
                        WissenschaftlicheAnalyseView(
                            titel: experimentTitel,
                            hatGeholfen: experimentHatGeholfen,
                            tageSeitStart: tageSeitStart
                        )
                    }

                    Spacer().frame(height: 30)
                }
            }
        }
        .navigationTitle("Auswertung")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
    
    func fazitText() -> String {
        if experimentAvgSchlaf == 0 {
            return "Noch nicht genug Daten. Mache mindestens 3 Check-ins in Woche 2 um ein Ergebnis zu sehen."
        } else if verbesserungGegenOnboarding > 1.5 {
            return "Starke Verbesserung! Dein Schlaf hat sich seit dem Start von ExperiSleep und durch dieses Experiment deutlich verbessert. Behalte diese Gewohnheit bei."
        } else if verbesserungGegenOnboarding > 0 {
            return "Leichte Verbesserung gegenüber deinem Ausgangswert. Führe das Experiment länger durch um sicherere Aussagen treffen zu können."
        } else {
            return "Dieses Experiment zeigt bei dir keine Verbesserung. Das ist wertvolles Wissen — probiere ein anderes Experiment aus."
        }
    }
}

struct VergleichsKarte: View {
    var label: String
    var wert: Double
    var farbe: Color
    var beschreibung: String
    var istVeraenderung: Bool = false
    var positiv: Bool = true
    
    var body: some View {
        VStack(spacing: 6) {
            Text(label)
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
            
            Text(istVeraenderung ? (positiv ? "+\(String(format: "%.1f", wert))" : "-\(String(format: "%.1f", wert))") : String(format: "%.1f", wert))
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(farbe)
            
            Text(beschreibung)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white.opacity(0.06))
        .cornerRadius(12)
    }
}

struct BalkenRow: View {
    var label: String
    var wert: Double
    var farbe: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(label)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                Spacer()
                Text(wert == 0 ? "—" : String(format: "%.1f", wert))
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(.white)
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 10)
                    RoundedRectangle(cornerRadius: 6)
                        .fill(farbe)
                        .frame(width: geo.size.width * CGFloat(wert / 10), height: 10)
                }
            }
            .frame(height: 10)
        }
    }
}

// MARK: - Wissenschaftliche Analyse

struct WissenschaftlicheAnalyseView: View {
    var titel: String
    var hatGeholfen: Bool
    var tageSeitStart: Int

    let cyan = Color(red: 0.0, green: 0.90, blue: 0.80)

    var analyse: ExperimentAnalyse { wissenschaftlicheAnalyse(fuer: titel) }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Header
            HStack(spacing: 10) {
                Image(systemName: "atom")
                    .foregroundColor(.purple)
                    .font(.system(size: 18))
                Text("Wissenschaftliche Analyse")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                if tageSeitStart >= 14 {
                    Text("Abgeschlossen")
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.2))
                        .foregroundColor(.green)
                        .cornerRadius(8)
                }
            }
            .padding()
            .padding(.bottom, 4)

            Divider().background(Color.white.opacity(0.1)).padding(.horizontal)

            // Mechanismus
            AnalyseBlock(
                icon: "gearshape.fill",
                farbe: cyan,
                titel: "Wie wirkt dieses Experiment?",
                text: analyse.mechanismus
            )

            Divider().background(Color.white.opacity(0.08)).padding(.horizontal)

            // Personalisierte Auswertung
            AnalyseBlock(
                icon: hatGeholfen ? "checkmark.seal.fill" : "questionmark.circle.fill",
                farbe: hatGeholfen ? .green : .orange,
                titel: hatGeholfen ? "Warum hat es bei dir geholfen" : "Warum hat es vielleicht nicht geholfen",
                text: hatGeholfen ? analyse.wennErfolgreich : analyse.wennNichtErfolgreich
            )

            Divider().background(Color.white.opacity(0.08)).padding(.horizontal)

            // Tipp
            AnalyseBlock(
                icon: "lightbulb.fill",
                farbe: .yellow,
                titel: "Tipp für die Zukunft",
                text: analyse.tipp
            )
        }
        .background(Color.white.opacity(0.06))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.purple.opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal)
    }
}

struct AnalyseBlock: View {
    var icon: String
    var farbe: Color
    var titel: String
    var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(farbe)
                    .font(.system(size: 13))
                Text(titel)
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(.white)
            }
            Text(text)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
                .lineSpacing(4)
        }
        .padding()
    }
}

struct StatKarte: View {
    var zahl: String
    var label: String
    var farbe: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(zahl)
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(farbe)
            Text(label)
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white.opacity(0.06))
        .cornerRadius(12)
    }
}

#Preview {
    NavigationView {
        AuswertungView(experimentTitel: "Kein Koffein nach 14 Uhr")
            .environmentObject(CheckInSpeicher())
    }
}
