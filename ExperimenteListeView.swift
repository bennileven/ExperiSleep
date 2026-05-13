import SwiftUI

struct ExperimenteListeView: View {
    @EnvironmentObject private var aktiveExperimente: AktiveExperimente
    @EnvironmentObject var theme: AppTheme
    @State private var zeigeErstellen = false
    @State private var eigeneExperimente: [EigenesExperiment] = []
    @State private var aktiveTab = 0

    let cyan = Color(red: 0.0, green: 0.90, blue: 0.80)
    private let speicherSchluessel = "eigeneExperimente"

    let kategorien: [(name: String, icon: String, farbe: Color, experimente: [(titel: String, icon: String, farbe: Color)])] = [
        (
            name: "Licht & Bildschirm",
            icon: "display",
            farbe: .blue,
            experimente: [
                (titel: "Kein Koffein nach 14 Uhr", icon: "cup.and.saucer.fill", farbe: .brown),
                (titel: "Handy weg ab 21 Uhr", icon: "iphone.slash", farbe: .blue),
                (titel: "Blaues Licht Filter ab 20 Uhr", icon: "eyeglasses", farbe: .indigo),
            ]
        ),
        (
            name: "Entspannung & Stress",
            icon: "brain.head.profile",
            farbe: .purple,
            experimente: [
                (titel: "10 Min Meditation vor Bett", icon: "brain.head.profile", farbe: .purple),
                (titel: "5 Min Tagebuch schreiben", icon: "square.and.pencil", farbe: .orange),
                (titel: "Atemübung vor dem Schlafen", icon: "wind", farbe: .teal),
            ]
        ),
        (
            name: "Ernährung & Körper",
            icon: "fork.knife.circle.fill",
            farbe: .green,
            experimente: [
                (titel: "Kein Essen nach 18 Uhr", icon: "fork.knife.circle.fill", farbe: .green),
                (titel: "Kein Alkohol unter der Woche", icon: "wineglass.fill", farbe: .red),
                (titel: "Jeden Tag 8 Gläser Wasser", icon: "drop.fill", farbe: .cyan),
            ]
        ),
        (
            name: "Bewegung & Umgebung",
            icon: "figure.walk",
            farbe: .mint,
            experimente: [
                (titel: "30 Min Spaziergang täglich", icon: "figure.walk", farbe: .mint),
                (titel: "Zimmer auf 18 Grad kühlen", icon: "thermometer.snowflake", farbe: .blue),
                (titel: "Kein Sport nach 20 Uhr", icon: "figure.run", farbe: .orange),
            ]
        ),
        (
            name: "Routine",
            icon: "clock.fill",
            farbe: .indigo,
            experimente: [
                (titel: "Jeden Tag gleiche Schlafzeit", icon: "clock.fill", farbe: .indigo),
                (titel: "10 Min Lesen statt Handy", icon: "book.fill", farbe: .brown),
                (titel: "Magnesium vor dem Schlafen", icon: "pills.fill", farbe: .purple),
            ]
        )
    ]

    var body: some View {
        ZStack {
            theme.hintergrund
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Text("Experiment starten")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(cyan)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom, 4)

                Picker("", selection: $aktiveTab) {
                    Text("Empfohlen").tag(0)
                    Text("Meine").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.vertical, 12)

                if aktiveTab == 0 {
                    empfohleneListe
                } else {
                    meineListe
                }
            }
        }
        .navigationTitle("")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .onAppear { laden() }
        .onChange(of: eigeneExperimente) { sichern() }
        .sheet(isPresented: $zeigeErstellen) {
            ExperimentErstellenView(experimente: $eigeneExperimente)
        }
    }

    // MARK: - Empfohlen Tab

    var empfohleneListe: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(kategorien, id: \.name) { kategorie in
                    NavigationLink(destination: KategorieDetailView(
                        kategorieName: kategorie.name,
                        kategorieIcon: kategorie.icon,
                        kategorieFarbe: kategorie.farbe,
                        experimente: kategorie.experimente
                    )) {
                        HStack(spacing: 16) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(kategorie.farbe.opacity(0.2))
                                    .frame(width: 44, height: 44)
                                Image(systemName: kategorie.icon)
                                    .foregroundColor(kategorie.farbe)
                                    .font(.system(size: 20))
                            }
                            VStack(alignment: .leading, spacing: 4) {
                                Text(kategorie.name)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text("\(kategorie.experimente.count) Experimente")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
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
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal)
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 30)
        }
    }

    // MARK: - Meine Tab

    var meineListe: some View {
        ZStack(alignment: .bottomTrailing) {
            Group {
                if eigeneExperimente.isEmpty {
                    leerZustand
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(eigeneExperimente) { experiment in
                                NavigationLink(destination: ExperimentDetailView(
                                    titel: experiment.titel,
                                    icon: experiment.icon,
                                    color: farbeVon(name: experiment.farbname)
                                )) {
                                    EigenesExperimentZeile(experiment: experiment)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .padding(.horizontal)
                                .contextMenu {
                                    Button(role: .destructive) {
                                        eigeneExperimente.removeAll { $0.id == experiment.id }
                                    } label: {
                                        Label("Löschen", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 100)
                    }
                }
            }

            // Erstellen-Button
            Button(action: { zeigeErstellen = true }) {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                    Text("Neu")
                }
                .font(.headline)
                .foregroundColor(theme.hintergrund)
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(cyan)
                .cornerRadius(30)
                .shadow(color: cyan.opacity(0.4), radius: 8, x: 0, y: 4)
            }
            .padding(.trailing, 24)
            .padding(.bottom, 30)
        }
    }

    var leerZustand: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "flask")
                .font(.system(size: 50))
                .foregroundColor(.white.opacity(0.2))
            Text("Noch keine eigenen Experimente")
                .font(.headline)
                .foregroundColor(.secondary)
            Text("Erstelle ein eigenes Experiment und teste was deinen Schlaf wirklich beeinflusst.")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.35))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Spacer()
        }
    }

    // MARK: - Persistenz

    func laden() {
        guard let data = UserDefaults.standard.data(forKey: speicherSchluessel),
              let decoded = try? JSONDecoder().decode([EigenesExperiment].self, from: data)
        else { return }
        eigeneExperimente = decoded
    }

    func sichern() {
        if let data = try? JSONEncoder().encode(eigeneExperimente) {
            UserDefaults.standard.set(data, forKey: speicherSchluessel)
        }
    }

    func farbeVon(name: String) -> Color {
        switch name {
        case "blue": return .blue
        case "green": return .green
        case "orange": return .orange
        case "pink": return .pink
        case "purple": return .purple
        case "red": return .red
        default: return .indigo
        }
    }
}

// MARK: - Zeile für eigenes Experiment

struct EigenesExperimentZeile: View {
    @EnvironmentObject var theme: AppTheme
    var experiment: EigenesExperiment

    func farbeVon(name: String) -> Color {
        switch name {
        case "blue": return .blue
        case "green": return .green
        case "orange": return .orange
        case "pink": return .pink
        case "purple": return .purple
        case "red": return .red
        default: return .indigo
        }
    }

    var farbe: Color { farbeVon(name: experiment.farbname) }

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(farbe.opacity(0.2))
                    .frame(width: 44, height: 44)
                Image(systemName: experiment.icon)
                    .foregroundColor(farbe)
                    .font(.system(size: 20))
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(experiment.titel)
                    .font(.headline)
                    .foregroundColor(.primary)
                if !experiment.beschreibung.isEmpty {
                    Text(experiment.beschreibung)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
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
                .stroke(farbe.opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
    NavigationView {
        ExperimenteListeView()
            .environmentObject(AktiveExperimente())
    }
}
