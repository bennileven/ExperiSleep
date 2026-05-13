import SwiftUI

struct RanglisteView: View {
    @EnvironmentObject var theme: AppTheme
    @AppStorage("nutzername") var nutzername = "Schläfer"
    @StateObject private var punkte = PunkteManager.shared

    let cyan = Color(red: 0.0, green: 0.90, blue: 0.80)

    @State private var eintraege: [RanglisteEintrag] = []
    @State private var laedt = true
    @State private var eigenerRang: Int? = nil

    var body: some View {
        ZStack {
            theme.hintergrund.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {

                    // ── Eigene Stats ──
                    EigeneStatsKarte(punkte: punkte.punkte, rang: eigenerRang, cyan: cyan)
                        .padding(.horizontal)
                        .padding(.top, 8)

                    // ── Punkteerklärung ──
                    PunkteErklarung(cyan: cyan)
                        .padding(.horizontal)

                    // ── Rangliste ──
                    VStack(spacing: 0) {
                        HStack {
                            Text("Community Rangliste")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Spacer()
                            Button(action: laden) {
                                Image(systemName: "arrow.clockwise")
                                    .foregroundColor(cyan)
                                    .font(.subheadline)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 10)

                        if laedt {
                            ProgressView()
                                .tint(cyan)
                                .padding(40)
                        } else if eintraege.isEmpty {
                            Text("Noch keine Einträge — sei der Erste! 🚀")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(40)
                        } else {
                            VStack(spacing: 8) {
                                ForEach(Array(eintraege.enumerated()), id: \.element.id) { index, eintrag in
                                    RangZeile(
                                        rang: index + 1,
                                        eintrag: eintrag,
                                        istEigener: eintrag.id == FirebaseManager.shared.nutzerID,
                                        cyan: cyan
                                    )
                                    .padding(.horizontal)
                                }
                            }
                        }
                    }

                    Spacer().frame(height: 40)
                }
                .padding(.top, 8)
            }
        }
        .navigationTitle("Rangliste")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .onAppear { laden() }
    }

    func laden() {
        laedt = true
        FirebaseManager.shared.ranglisteLaden { ergebnis in
            eintraege = ergebnis
            laedt = false
            eigenerRang = ergebnis.firstIndex(where: { $0.id == FirebaseManager.shared.nutzerID }).map { $0 + 1 }
        }
    }
}

// MARK: - Eigene Stats

struct EigeneStatsKarte: View {
    var punkte: Int
    var rang: Int?
    var cyan: Color
    @EnvironmentObject var theme: AppTheme

    var rangText: String {
        guard let r = rang else { return "–" }
        return "#\(r)"
    }

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Deine Punkte")
                    .font(.caption)
                    .foregroundColor(.secondary)
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(punkte)")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(cyan)
                    Text("XP")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("Dein Rang")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(rangText)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.primary)
            }
        }
        .padding()
        .background(theme.karte)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(cyan.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Punkteerklärung

struct PunkteErklarung: View {
    var cyan: Color
    @EnvironmentObject var theme: AppTheme

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("So verdienst du XP")
                .font(.subheadline)
                .bold()
                .foregroundColor(.primary)

            HStack(spacing: 0) {
                VStack(spacing: 6) {
                    XPZeile(icon: "checkmark.circle.fill", farbe: .green,  text: "Täglicher Check-in",        xp: "+10 XP")
                    XPZeile(icon: "flame.fill",            farbe: .orange, text: "7-Tage Streak",             xp: "+50 XP")
                }
                Spacer()
                VStack(spacing: 6) {
                    XPZeile(icon: "trophy.fill",           farbe: .yellow, text: "14-Tage Streak",            xp: "+100 XP")
                    XPZeile(icon: "flask.fill",            farbe: .indigo, text: "Experiment abgeschlossen",  xp: "+100 XP")
                }
            }
        }
        .padding()
        .background(theme.karte)
        .cornerRadius(14)
    }
}

struct XPZeile: View {
    var icon: String
    var farbe: Color
    var text: String
    var xp: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundColor(farbe)
                .font(.system(size: 12))
            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
            Text(xp)
                .font(.caption)
                .bold()
                .foregroundColor(.primary)
        }
    }
}

// MARK: - Rang-Zeile

struct RangZeile: View {
    var rang: Int
    var eintrag: RanglisteEintrag
    var istEigener: Bool
    var cyan: Color
    @EnvironmentObject var theme: AppTheme

    var rangSymbol: String {
        switch rang {
        case 1: return "🥇"
        case 2: return "🥈"
        case 3: return "🥉"
        default: return "\(rang)."
        }
    }

    var hintergrund: Color {
        if istEigener { return cyan.opacity(0.1) }
        if rang <= 3   { return Color.yellow.opacity(0.06) }
        return theme.karte
    }

    var body: some View {
        HStack(spacing: 12) {
            Text(rangSymbol)
                .font(rang <= 3 ? .title3 : .subheadline)
                .frame(width: 36)
                .foregroundColor(.primary)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(eintrag.anzeigeName)
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(istEigener ? cyan : .primary)
                    if istEigener {
                        Text("Du")
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(cyan.opacity(0.2))
                            .foregroundColor(cyan)
                            .cornerRadius(6)
                    }
                }
                HStack(spacing: 10) {
                    Label("\(eintrag.streak) Streak", systemImage: "flame.fill")
                        .font(.caption2)
                        .foregroundColor(.orange)
                    Label("\(eintrag.experimente) Exp.", systemImage: "flask.fill")
                        .font(.caption2)
                        .foregroundColor(.indigo)
                }
                .labelStyle(.titleAndIcon)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("\(eintrag.punkte)")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(rang <= 3 ? .yellow : .primary)
                Text("XP")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(hintergrund)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(istEigener ? cyan.opacity(0.4) : Color.clear, lineWidth: 1)
        )
    }
}

#Preview {
    NavigationView {
        RanglisteView()
            .environmentObject(AppTheme())
    }
}
