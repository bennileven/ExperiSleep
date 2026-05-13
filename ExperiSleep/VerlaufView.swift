import SwiftUI

struct VerlaufView: View {
    @EnvironmentObject private var aktiveExperimente: AktiveExperimente
    @EnvironmentObject private var speicher: CheckInSpeicher

    let cyan = Color(red: 0.0, green: 0.90, blue: 0.80)

    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.11, blue: 0.24)
                .ignoresSafeArea()

            if aktiveExperimente.vergangene.isEmpty {
                leerZustand
            } else {
                ScrollView {
                    VStack(spacing: 14) {
                        ForEach(aktiveExperimente.vergangene) { experiment in
                            NavigationLink(destination:
                                AuswertungView(experimentTitel: experiment.titel)
                                    .environmentObject(speicher)
                            ) {
                                VerlaufZeile(experiment: experiment, speicher: speicher, cyan: cyan)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationTitle("Vergangene Experimente")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }

    var leerZustand: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 50))
                .foregroundColor(.white.opacity(0.2))
            Text("Noch keine abgeschlossenen Experimente")
                .font(.headline)
                .foregroundColor(.white.opacity(0.5))
            Text("Starte dein erstes Experiment und stoppe es nach 14 Tagen — dann erscheint es hier.")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.35))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
}

// MARK: - Zeile

struct VerlaufZeile: View {
    var experiment: AbgeschlossenesExperiment
    var speicher: CheckInSpeicher
    var cyan: Color

    var meta: (icon: String, farbe: Color) { iconUndFarbe(fuer: experiment.titel) }

    var schlafDurchschnitt: Double {
        let eintraege = speicher.eintraegeFor(experiment: experiment.titel)
        guard !eintraege.isEmpty else { return 0 }
        return Double(eintraege.reduce(0) { $0 + $1.schlafqualitaet }) / Double(eintraege.count)
    }

    var checkInAnzahl: Int {
        speicher.eintraegeFor(experiment: experiment.titel).count
    }

    var datumsText: String {
        let f = DateFormatter()
        f.dateFormat = "dd.MM.yy"
        return "\(f.string(from: experiment.startDatum)) – \(f.string(from: experiment.endDatum))"
    }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(meta.farbe.opacity(0.2))
                    .frame(width: 48, height: 48)
                Image(systemName: meta.icon)
                    .foregroundColor(meta.farbe)
                    .font(.system(size: 22))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(experiment.titel)
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(.white)
                    .lineLimit(1)

                Text(datumsText)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.45))

                HStack(spacing: 10) {
                    Label("\(experiment.dauerInTagen) Tage", systemImage: "calendar")
                    Label("\(checkInAnzahl) Check-ins", systemImage: "checkmark.circle")
                    if schlafDurchschnitt > 0 {
                        Label(String(format: "Ø %.1f", schlafDurchschnitt), systemImage: "moon.fill")
                    }
                }
                .font(.caption2)
                .foregroundColor(.white.opacity(0.5))
                .labelStyle(.titleAndIcon)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.white.opacity(0.25))
                .font(.caption)
        }
        .padding()
        .background(Color.white.opacity(0.06))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }
}

// MARK: - Icon-Lookup

func iconUndFarbe(fuer titel: String) -> (icon: String, farbe: Color) {
    let tabelle: [(String, String, Color)] = [
        ("Kein Koffein nach 14 Uhr",       "cup.and.saucer.fill",      .brown),
        ("Handy weg ab 21 Uhr",             "iphone.slash",             .blue),
        ("Blaues Licht Filter ab 20 Uhr",   "eyeglasses",               .indigo),
        ("10 Min Meditation vor Bett",       "brain.head.profile",       .purple),
        ("5 Min Tagebuch schreiben",         "square.and.pencil",        .orange),
        ("Atemübung vor dem Schlafen",       "wind",                     .teal),
        ("Kein Essen nach 18 Uhr",           "fork.knife.circle.fill",   .green),
        ("Kein Alkohol unter der Woche",     "wineglass.fill",           .red),
        ("Jeden Tag 8 Gläser Wasser",        "drop.fill",                .cyan),
        ("30 Min Spaziergang täglich",       "figure.walk",              .mint),
        ("Zimmer auf 18 Grad kühlen",        "thermometer.snowflake",    .blue),
        ("Kein Sport nach 20 Uhr",           "figure.run",               .orange),
        ("Jeden Tag gleiche Schlafzeit",     "clock.fill",               .indigo),
        ("10 Min Lesen statt Handy",         "book.fill",                .brown),
        ("Magnesium vor dem Schlafen",       "pills.fill",               .purple),
    ]
    if let treffer = tabelle.first(where: { $0.0 == titel }) {
        return (treffer.1, treffer.2)
    }
    return ("flask.fill", .indigo)
}

#Preview {
    NavigationView {
        VerlaufView()
            .environmentObject(AktiveExperimente())
            .environmentObject(CheckInSpeicher())
    }
}
