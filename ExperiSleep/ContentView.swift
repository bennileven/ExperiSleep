import SwiftUI

struct ContentView: View {
    @State private var zeigeErstellen = false
    @State private var zeigeCheckIn = false
    @State private var meilensteinZuZeigen: Int? = nil
    @AppStorage("gezeigterStreakMeilenstein") var gezeigterMeilenstein = 0
    @EnvironmentObject private var aktiveExperimente: AktiveExperimente
    @EnvironmentObject private var speicher: CheckInSpeicher
    @EnvironmentObject var theme: AppTheme
    
    let cyan = Color(red: 0.0, green: 0.90, blue: 0.80)
    @AppStorage("baselineSchlaf") var baselineSchlaf = 5.0
    @AppStorage("demoModus") var demoModus = false
    
    var aktivesExperiment: String {
        aktiveExperimente.aktiveNamen.first ?? "Allgemein"
    }

    let demoExperimentTitel = "Kein Koffein nach 14 Uhr"

    var heuteCheckInGemacht: Bool {
        let heute = Calendar.current.startOfDay(for: Date())
        return speicher.eintraege.contains {
            Calendar.current.startOfDay(for: $0.datum) == heute
        }
    }

    var angezeigterCheckIn: Bool { demoModus ? true : heuteCheckInGemacht }

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

    var angezeigterStreak: Int { demoModus ? 14 : streak }
    
    var durchschnittSchlafLetzte7Tage: Double {
        let eintraege = demoModus ? demoDaten() : speicher.eintraege
        let vor7Tagen = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        let relevant = eintraege.filter { $0.datum >= vor7Tagen }
        guard !relevant.isEmpty else { return 0 }
        return Double(relevant.reduce(0) { $0 + $1.schlafqualitaet }) / Double(relevant.count)
    }
    
    var effektiverBaselineWert: Double { demoModus ? 5.0 : baselineSchlaf }

    var trendPfeil: String {
        let diff = durchschnittSchlafLetzte7Tage - effektiverBaselineWert
        if diff > 0.5 { return "arrow.up.circle.fill" }
        if diff < -0.5 { return "arrow.down.circle.fill" }
        return "minus.circle.fill"
    }

    var trendFarbe: Color {
        let diff = durchschnittSchlafLetzte7Tage - effektiverBaselineWert
        if diff > 0.5 { return .green }
        if diff < -0.5 { return .red }
        return .orange
    }
    
    var graphEintraege: [CheckInEintrag] {
        if demoModus { return demoDaten() }
        let sortiert = speicher.eintraege.sorted { $0.datum < $1.datum }
        if let start = aktiveExperimente.aktive.first?.startDatum {
            return sortiert.filter { $0.datum >= start }
        }
        return Array(sortiert.suffix(14))
    }
    
    func demoDaten() -> [CheckInEintrag] {
        let schlafWerte = [4, 3, 6, 7, 7, 8, 8, 7, 8, 8, 9, 9, 8, 9]
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
                theme.hintergrund
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        
                        // ── Header ──
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Guten Morgen 👋")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                HStack(spacing: 0) {
                                    Text("Experi")
                                        .font(.title)
                                        .bold()
                                        .foregroundColor(.primary)
                                    Text("Sleep")
                                        .font(.title)
                                        .bold()
                                        .foregroundColor(cyan)
                                }
                            }
                            Spacer()
                            HStack(spacing: 10) {
                                NavigationLink(destination: RanglisteView()
                                    .environmentObject(theme)
                                ) {
                                    ZStack {
                                        Circle()
                                            .fill(theme.karte)
                                            .frame(width: 44, height: 44)
                                        Image(systemName: "trophy.fill")
                                            .foregroundColor(.yellow)
                                            .font(.system(size: 18))
                                    }
                                }
                                NavigationLink(destination: ProfilView()
                                    .environmentObject(speicher)
                                    .environmentObject(aktiveExperimente)
                                ) {
                                    ZStack {
                                        Circle()
                                            .fill(theme.karte)
                                            .frame(width: 44, height: 44)
                                        Image(systemName: "person.fill")
                                            .foregroundColor(cyan)
                                            .font(.system(size: 20))
                                    }
                                }
                            }
                        } // ← HStack Ende
                        .padding(.horizontal)
                        .padding(.top, 50)
                        
                        // ── Streak & Check-in Karte ──
                        VStack(spacing: 16) {
                            HStack(spacing: 20) {
                                VStack(spacing: 4) {
                                    Text("\(angezeigterStreak)")
                                        .font(.system(size: 40, weight: .bold))
                                        .foregroundColor(angezeigterStreak >= 7 ? .orange : cyan)
                                    Text("Tage Streak")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }

                                Divider()
                                    .background(Color.primary.opacity(0.15))
                                    .frame(height: 50)

                                VStack(spacing: 4) {
                                    Text(angezeigterStreak >= 7 ? "🔥" : angezeigterStreak >= 3 ? "🌱" : "😴")
                                        .font(.system(size: 36))
                                    Text(angezeigterStreak >= 7 ? "On fire!" : angezeigterStreak >= 3 ? "Guter Start" : "Fang an!")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                HStack(spacing: 6) {
                                    ForEach(0..<7) { tag in
                                        let hatEintrag = demoModus ? true : hatEintragFuerTag(tag: tag)
                                        Circle()
                                            .fill(hatEintrag ? cyan : Color.primary.opacity(0.1))
                                            .frame(width: 10, height: 10)
                                    }
                                }
                            }
                            .padding(.horizontal)

                            HStack {
                                Circle()
                                    .fill(Color.green)
                                    .frame(width: 6, height: 6)
                                Text("Aktiv: \(demoModus ? demoExperimentTitel : aktivesExperiment)")
                                    .font(.caption)
                                    .foregroundColor(.green.opacity(0.9))
                                Spacer()
                            }
                            .padding(.horizontal)
                            .opacity(demoModus || !aktiveExperimente.aktive.isEmpty ? 1 : 0)

                            Button(action: { zeigeCheckIn = true }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(angezeigterCheckIn ? "Check-in erledigt ✓" : "Täglicher Check-in")
                                            .font(.headline)
                                            .foregroundColor(angezeigterCheckIn ? .green : theme.hintergrund)
                                        Text(angezeigterCheckIn ? "Morgen wieder!" : aktiveExperimente.aktive.isEmpty ? "Starte zuerst ein Experiment" : "Für: \(aktivesExperiment)")
                                            .font(.caption)
                                            .foregroundColor(angezeigterCheckIn ? .green.opacity(0.8) : theme.hintergrund.opacity(0.7))
                                    }
                                    Spacer()
                                    Image(systemName: angezeigterCheckIn ? "checkmark.circle.fill" : "moon.fill")
                                        .font(.title2)
                                        .foregroundColor(angezeigterCheckIn ? .green : theme.hintergrund)
                                }
                                .padding()
                                .background(angezeigterCheckIn ? Color.green.opacity(0.15) : cyan)
                                .cornerRadius(14)
                            }
                            .padding(.horizontal)
                            .disabled(angezeigterCheckIn || (!demoModus && aktiveExperimente.aktive.isEmpty))
                        }
                        .padding(.vertical)
                        .background(theme.karte)
                        .cornerRadius(20)
                        .padding(.horizontal)
                        
                        // ── Laufendes Experiment ──
                        if demoModus {
                            // Demo-Experimentkarte
                            VStack(spacing: 10) {
                                HStack {
                                    Image(systemName: "cup.and.saucer.fill")
                                        .foregroundColor(.indigo)
                                        .frame(width: 30)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(demoExperimentTitel)
                                            .font(.body)
                                            .foregroundColor(.primary)
                                        Text("Tag 8 von 14")
                                            .font(.caption)
                                            .foregroundColor(.green.opacity(0.8))
                                    }
                                    Spacer()
                                    Circle()
                                        .fill(Color.green)
                                        .frame(width: 8, height: 8)
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.secondary)
                                        .font(.caption)
                                }
                                GeometryReader { geo in
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Color.green.opacity(0.15))
                                            .frame(height: 6)
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Color.green)
                                            .frame(width: geo.size.width * (8.0 / 14.0), height: 6)
                                    }
                                }
                                .frame(height: 6)
                            }
                            .padding()
                            .background(Color.green.opacity(0.08))
                            .cornerRadius(14)
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.green.opacity(0.2), lineWidth: 1))
                            .padding(.horizontal)
                        } else if !aktiveExperimente.aktive.isEmpty {
                            ForEach(aktiveExperimente.aktiveNamen, id: \.self) { titel in
                                NavigationLink(destination: ExperimentDetailView(
                                    titel: titel,
                                    icon: "moon.stars.fill",
                                    color: .indigo
                                )) {
                                    VStack(spacing: 10) {
                                        HStack {
                                            Image(systemName: "moon.stars.fill")
                                                .foregroundColor(.indigo)
                                                .frame(width: 30)
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(titel)
                                                    .font(.body)
                                                    .foregroundColor(.primary)
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
                                                .foregroundColor(.secondary)
                                                .font(.caption)
                                        }
                                        if let start = aktiveExperimente.startDatum(fuer: titel) {
                                            let tage = min(Calendar.current.dateComponents([.day], from: start, to: Date()).day ?? 0, 13)
                                            let fortschritt = CGFloat(tage + 1) / 14.0
                                            GeometryReader { geo in
                                                ZStack(alignment: .leading) {
                                                    RoundedRectangle(cornerRadius: 4)
                                                        .fill(Color.green.opacity(0.15))
                                                        .frame(height: 6)
                                                    RoundedRectangle(cornerRadius: 4)
                                                        .fill(Color.green)
                                                        .frame(width: geo.size.width * fortschritt, height: 6)
                                                        .animation(.easeInOut(duration: 0.6), value: fortschritt)
                                                }
                                            }
                                            .frame(height: 6)
                                        }
                                    }
                                    .padding()
                                    .background(Color.green.opacity(0.08))
                                    .cornerRadius(14)
                                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.green.opacity(0.2), lineWidth: 1))
                                }
                                .buttonStyle(PlainButtonStyle())
                                .padding(.horizontal)
                            }
                        }

                        // ── Schlaf Dashboard ──
                        VStack(spacing: 16) {
                            HStack {
                                Text("Mein Schlaf")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                
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
                                    ).environmentObject(speicher).environmentObject(theme)) {
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
                                    wert: String(format: "%.1f", effektiverBaselineWert),
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
                                    baselineWert: effektiverBaselineWert
                                )
                            } else {
                                HStack {
                                    Image(systemName: "chart.bar.fill")
                                        .foregroundColor(.secondary)
                                    Text("Noch keine Daten — mache deinen ersten Check-in!")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.primary.opacity(0.04))
                                .cornerRadius(14)
                                .padding(.horizontal)
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
                                    .foregroundColor(.secondary)
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
                pruefeStreakMeilenstein()
            }
            .onChange(of: streak) { _ in pruefeStreakMeilenstein() }
            .sheet(isPresented: $zeigeCheckIn) {
                CheckInView(experimentTitel: aktivesExperiment)
                    .environmentObject(speicher)
                    .environmentObject(theme)
            }
            .overlay {
                if let tage = meilensteinZuZeigen {
                    StreakMeilensteinView(tage: tage) {
                        meilensteinZuZeigen = nil
                    }
                    .transition(.opacity)
                    .zIndex(99)
                }
            }
            .sheet(item: $aktiveExperimente.neuAbgeschlossen) { experiment in
                ExperimentAbschlussView(experiment: experiment)
                    .environmentObject(speicher)
                    .environmentObject(aktiveExperimente)
            }
        }
    }
    
    func pruefeStreakMeilenstein() {
        if streak < gezeigterMeilenstein { gezeigterMeilenstein = 0 }
        for m in [7, 14] where streak >= m && gezeigterMeilenstein < m {
            meilensteinZuZeigen = m
            gezeigterMeilenstein = m
            PunkteManager.shared.streakMeilenstein(tage: m)
            break
        }
        // Streak immer aktuell halten für Rangliste
        UserDefaults.standard.set(streak, forKey: "letzterStreak")
        UserDefaults.standard.set(aktiveExperimente.vergangene.count, forKey: "abgeschlosseneExperimente")
        PunkteManager.shared.sync()
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
    @EnvironmentObject var theme: AppTheme
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
                .foregroundColor(.primary)
            Text(einheit)
                .font(.caption2)
                .foregroundColor(.secondary)
            Text(titel)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(theme.karte)
        .cornerRadius(12)
    }
}

struct DunklesExperimentButton: View {
    @EnvironmentObject var theme: AppTheme
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
                .foregroundColor(.primary)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .padding()
        .background(theme.karte)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.primary.opacity(0.1), lineWidth: 1)
        )
    }
}

#Preview {
    ContentView()
        .environmentObject(AktiveExperimente())
        .environmentObject(CheckInSpeicher())
}
