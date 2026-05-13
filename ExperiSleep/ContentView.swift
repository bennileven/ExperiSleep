import SwiftUI

struct ContentView: View {
    @State private var zeigeErstellen = false
    @State private var zeigeCheckIn = false
    @EnvironmentObject private var aktiveExperimente: AktiveExperimente
    @EnvironmentObject private var speicher: CheckInSpeicher
    
    let cyan = Color(red: 0.0, green: 0.90, blue: 0.80)
    @AppStorage("baselineSchlaf") var baselineSchlaf = 5.0
    @AppStorage("demoModus") var demoModus = false
    
    var aktivesExperiment: String {
        aktiveExperimente.aktiveNamen.first ?? "Allgemein"
    }
    
    var heuteCheckInGemacht: Bool {
        let heute = Calendar.current.startOfDay(for: Date())
        return speicher.eintraege.contains {
            Calendar.current.startOfDay(for: $0.datum) == heute
        }
    }
    
    var streak: Int {
        var count = 0
        var pruefdatum = Calendar.current.startOfDay(for: Date())
        let sortiert = speicher.eintraege.sorted { $0.datum > $1.datum }
        for eintrag in sortiert {
            let tag = Calendar.current.startOfDay(for: eintrag.datum)
            if tag == pruefdatum {
                count += 1
                pruefdatum = Calendar.current.date(byAdding: .day, value: -1, to: pruefdatum)!
            } else { break }
        }
        return count
    }
    
    var durchschnittSchlafLetzte7Tage: Double {
        let eintraege = demoModus ? demoDaten() : speicher.eintraege
        let vor7Tagen = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        let relevant = eintraege.filter { $0.datum >= vor7Tagen }
        guard !relevant.isEmpty else { return 0 }
        return Double(relevant.reduce(0) { $0 + $1.schlafqualitaet }) / Double(relevant.count)
    }
    
    var trendPfeil: String {
        let diff = durchschnittSchlafLetzte7Tage - baselineSchlaf
        if diff > 0.5 { return "arrow.up.circle.fill" }
        if diff < -0.5 { return "arrow.down.circle.fill" }
        return "minus.circle.fill"
    }
    
    var trendFarbe: Color {
        let diff = durchschnittSchlafLetzte7Tage - baselineSchlaf
        if diff > 0.5 { return .green }
        if diff < -0.5 { return .red }
        return .orange
    }
    
    var graphEintraege: [CheckInEintrag] {
        if demoModus { return demoDaten() }
        return Array(speicher.eintraege.sorted { $0.datum < $1.datum }.suffix(14))
    }
    
    func demoDaten() -> [CheckInEintrag] {
        let schlafWerte = [5, 4, 6, 5, 4, 5, 7, 8, 7, 8, 9, 8, 9, 8]
        let energieWerte = [5, 5, 5, 6, 4, 5, 6, 7, 7, 8, 7, 8, 8, 7]
        let stressWerte = [6, 7, 5, 6, 7, 6, 4, 3, 4, 3, 3, 2, 3, 3]
        guard let basisDatum = Calendar.current.date(byAdding: .day, value: -13, to: Date()) else { return [] }
        return (0..<14).compactMap { index in
            guard let datum = Calendar.current.date(byAdding: .day, value: index, to: basisDatum) else { return nil }
            return CheckInEintrag(
                datum: datum.addingTimeInterval(8 * 3600),
                schlafqualitaet: schlafWerte[index],
                energie: energieWerte[index],
                stress: stressWerte[index],
                experimentTitel: aktivesExperiment,
                istBaseline: false
            )
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.05, green: 0.11, blue: 0.24)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        
                        // ── Header ──
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Guten Morgen 👋")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.6))
                                HStack(spacing: 0) {
                                    Text("Experi")
                                        .font(.title)
                                        .bold()
                                        .foregroundColor(.white)
                                    Text("Sleep")
                                        .font(.title)
                                        .bold()
                                        .foregroundColor(cyan)
                                }
                            }
                            Spacer()
                            NavigationLink(destination: ProfilView()
                                .environmentObject(speicher)
                                .environmentObject(aktiveExperimente)
                            ) {
                                ZStack {
                                    Circle()
                                        .fill(Color.white.opacity(0.08))
                                        .frame(width: 44, height: 44)
                                    Image(systemName: "person.fill")
                                        .foregroundColor(cyan)
                                        .font(.system(size: 20))
                                }
                            }
                        } // ← HStack Ende
                        .padding(.horizontal)
                        .padding(.top, 50)
                        
                        // ── Streak & Check-in Karte ──
                        VStack(spacing: 16) {
                            HStack(spacing: 20) {
                                VStack(spacing: 4) {
                                    Text("\(streak)")
                                        .font(.system(size: 40, weight: .bold))
                                        .foregroundColor(streak >= 7 ? .orange : cyan)
                                    Text("Tage Streak")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.6))
                                }
                                
                                Divider()
                                    .background(Color.white.opacity(0.2))
                                    .frame(height: 50)
                                
                                VStack(spacing: 4) {
                                    Text(streak >= 7 ? "🔥" : streak >= 3 ? "🌱" : "😴")
                                        .font(.system(size: 36))
                                    Text(streak >= 7 ? "On fire!" : streak >= 3 ? "Guter Start" : "Fang an!")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.6))
                                }
                                
                                Spacer()
                                
                                HStack(spacing: 6) {
                                    ForEach(0..<7) { tag in
                                        let hatEintrag = hatEintragFuerTag(tag: tag)
                                        Circle()
                                            .fill(hatEintrag ? cyan : Color.white.opacity(0.15))
                                            .frame(width: 10, height: 10)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            
                            if !aktiveExperimente.aktive.isEmpty {
                                HStack {
                                    Circle()
                                        .fill(Color.green)
                                        .frame(width: 6, height: 6)
                                    Text("Aktiv: \(aktivesExperiment)")
                                        .font(.caption)
                                        .foregroundColor(.green.opacity(0.9))
                                    Spacer()
                                }
                                .padding(.horizontal)
                            }
                            
                            Button(action: { zeigeCheckIn = true }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(heuteCheckInGemacht ? "Check-in erledigt ✓" : "Täglicher Check-in")
                                            .font(.headline)
                                            .foregroundColor(heuteCheckInGemacht ? .green : Color(red: 0.05, green: 0.11, blue: 0.24))
                                        Text(heuteCheckInGemacht ? "Morgen wieder!" : aktiveExperimente.aktive.isEmpty ? "Starte zuerst ein Experiment" : "Für: \(aktivesExperiment)")
                                            .font(.caption)
                                            .foregroundColor(heuteCheckInGemacht ? .green.opacity(0.8) : Color(red: 0.05, green: 0.11, blue: 0.24).opacity(0.7))
                                    }
                                    Spacer()
                                    Image(systemName: heuteCheckInGemacht ? "checkmark.circle.fill" : "moon.fill")
                                        .font(.title2)
                                        .foregroundColor(heuteCheckInGemacht ? .green : Color(red: 0.05, green: 0.11, blue: 0.24))
                                }
                                .padding()
                                .background(heuteCheckInGemacht ? Color.green.opacity(0.15) : cyan)
                                .cornerRadius(14)
                            }
                            .padding(.horizontal)
                            .disabled(heuteCheckInGemacht || aktiveExperimente.aktive.isEmpty)
                        }
                        .padding(.vertical)
                        .background(Color.white.opacity(0.06))
                        .cornerRadius(20)
                        .padding(.horizontal)
                        
                        // ── Schlaf Dashboard ──
                        VStack(spacing: 16) {
                            HStack {
                                Text("Mein Schlaf")
                                    .font(.headline)
                                    .foregroundColor(.white.opacity(0.7))
                                
                                if demoModus {
                                    Text("Demo")
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 2)
                                        .background(Color.purple.opacity(0.3))
                                        .foregroundColor(.purple)
                                        .cornerRadius(8)
                                }
                                
                                Spacer()
                                if !aktiveExperimente.aktive.isEmpty {
                                    NavigationLink(destination: AuswertungView(
                                        experimentTitel: aktivesExperiment
                                    ).environmentObject(speicher)) {
                                        Text("Details")
                                            .font(.caption)
                                            .foregroundColor(cyan)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            
                            HStack(spacing: 12) {
                                DashboardKarte(
                                    titel: "Ausgangswert",
                                    wert: String(format: "%.1f", baselineSchlaf),
                                    einheit: "/10",
                                    icon: "moon.fill",
                                    farbe: .gray
                                )
                                DashboardKarte(
                                    titel: "Ø letzte 7 Tage",
                                    wert: durchschnittSchlafLetzte7Tage > 0 ? String(format: "%.1f", durchschnittSchlafLetzte7Tage) : "—",
                                    einheit: "/10",
                                    icon: trendPfeil,
                                    farbe: trendFarbe
                                )
                                DashboardKarte(
                                    titel: "Check-ins",
                                    wert: "\(demoModus ? 14 : speicher.eintraege.count)",
                                    einheit: "gesamt",
                                    icon: "checkmark.circle.fill",
                                    farbe: .indigo
                                )
                            }
                            .padding(.horizontal)
                            
                            if demoModus || !speicher.eintraege.isEmpty {
                                SchlafGraphView(
                                    eintraege: graphEintraege,
                                    baselineWert: baselineSchlaf
                                )
                            } else {
                                HStack {
                                    Image(systemName: "chart.bar.fill")
                                        .foregroundColor(.white.opacity(0.3))
                                    Text("Noch keine Daten — mache deinen ersten Check-in!")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.4))
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.white.opacity(0.04))
                                .cornerRadius(14)
                                .padding(.horizontal)
                            }
                        }
                        
                        // ── Laufende Experimente ──
                        if !aktiveExperimente.aktive.isEmpty {
                            VStack(spacing: 12) {
                                HStack {
                                    Circle()
                                        .fill(Color.green)
                                        .frame(width: 8, height: 8)
                                    Text("Laufende Experimente")
                                        .font(.headline)
                                        .foregroundColor(.white.opacity(0.7))
                                    Spacer()
                                    Text("\(aktiveExperimente.aktive.count) aktiv")
                                        .font(.caption)
                                        .foregroundColor(.green.opacity(0.8))
                                }
                                .padding(.horizontal)
                                
                                ForEach(aktiveExperimente.aktiveNamen, id: \.self) { titel in
                                    NavigationLink(destination: ExperimentDetailView(
                                        titel: titel,
                                        icon: "moon.stars.fill",
                                        color: .indigo
                                    )) {
                                        HStack {
                                            Image(systemName: "moon.stars.fill")
                                                .foregroundColor(.indigo)
                                                .frame(width: 30)
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(titel)
                                                    .font(.body)
                                                    .foregroundColor(.white)
                                                if let start = aktiveExperimente.startDatum(fuer: titel) {
                                                    let tage = Calendar.current.dateComponents([.day], from: start, to: Date()).day ?? 0
                                                    Text("Tag \(tage + 1) von 14")
                                                        .font(.caption)
                                                        .foregroundColor(.green.opacity(0.8))
                                                }
                                            }
                                            Spacer()
                                            Circle()
                                                .fill(Color.green)
                                                .frame(width: 8, height: 8)
                                            Image(systemName: "chevron.right")
                                                .foregroundColor(.white.opacity(0.3))
                                                .font(.caption)
                                        }
                                        .padding()
                                        .background(Color.green.opacity(0.08))
                                        .cornerRadius(14)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 14)
                                                .stroke(Color.green.opacity(0.2), lineWidth: 1)
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .padding(.horizontal)
                                }
                            }
                        }
                        
                        // ── Experiment starten Button ──
                        NavigationLink(destination: ExperimenteListeView()) {
                            HStack {
                                Image(systemName: "flask.fill")
                                    .foregroundColor(cyan)
                                Text("Experiment starten")
                                    .font(.headline)
                                    .foregroundColor(cyan)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.white.opacity(0.3))
                                    .font(.caption)
                            }
                            .padding()
                            .background(cyan.opacity(0.1))
                            .cornerRadius(14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(cyan.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle("")
            #if os(iOS)
            .navigationBarHidden(true)
            #endif
            .onAppear {
                NotificationManager.shared.erinnerungenPlanen()
                if heuteCheckInGemacht {
                    NotificationManager.shared.abendErinnerungDeaktivieren()
                }
            }
            .sheet(isPresented: $zeigeCheckIn) {
                CheckInView(experimentTitel: aktivesExperiment)
                    .environmentObject(speicher)
            }
        }
    }
    
    func hatEintragFuerTag(tag: Int) -> Bool {
        let datum = Calendar.current.date(byAdding: .day, value: -(6 - tag), to: Date())!
        let zielTag = Calendar.current.startOfDay(for: datum)
        return speicher.eintraege.contains {
            Calendar.current.startOfDay(for: $0.datum) == zielTag
        }
    }
}

struct DashboardKarte: View {
    var titel: String
    var wert: String
    var einheit: String
    var icon: String
    var farbe: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(farbe)
                .font(.system(size: 20))
            Text(wert)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
            Text(einheit)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.5))
            Text(titel)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.5))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.06))
        .cornerRadius(12)
    }
}

struct DunklesExperimentButton: View {
    var title: String
    var icon: String
    var color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 30)
            Text(title)
                .font(.body)
                .foregroundColor(.white)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.white.opacity(0.3))
                .font(.caption)
        }
        .padding()
        .background(Color.white.opacity(0.08))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

#Preview {
    ContentView()
        .environmentObject(AktiveExperimente())
        .environmentObject(CheckInSpeicher())
}
