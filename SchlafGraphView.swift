import SwiftUI

struct SchlafGraphView: View {
    var eintraege: [CheckInEintrag]
    var baselineWert: Double

    @EnvironmentObject var theme: AppTheme
    let cyan = Color(red: 0.0, green: 0.90, blue: 0.80)
    @State private var aktiveAnsicht = 0

    var sortiertEintraege: [CheckInEintrag] {
        Array(eintraege.sorted { $0.datum < $1.datum }.suffix(14))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            HStack {
                Text("Schlafverlauf")
                    .font(.headline)
                    .foregroundColor(.secondary)
                Spacer()
                HStack(spacing: 5) {
                    ForEach(0..<2) { i in
                        Circle()
                            .fill(aktiveAnsicht == i ? cyan : Color.white.opacity(0.25))
                            .frame(width: 6, height: 6)
                            .animation(.easeInOut(duration: 0.2), value: aktiveAnsicht)
                    }
                }
            }

            if sortiertEintraege.isEmpty {
                Text("Noch keine Daten vorhanden")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                TabView(selection: $aktiveAnsicht) {
                    BalkenAnsicht(
                        eintraege: sortiertEintraege,
                        baselineWert: baselineWert,
                        cyan: cyan
                    )
                    .tag(0)

                    KurvenAnsicht(
                        eintraege: sortiertEintraege,
                        baselineWert: baselineWert,
                        cyan: cyan
                    )
                    .tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 240)

                let besserAlsBaseline = sortiertEintraege.filter {
                    Double($0.schlafqualitaet) >= baselineWert
                }.count

                HStack(spacing: 8) {
                    Image(systemName: besserAlsBaseline > sortiertEintraege.count / 2 ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                        .foregroundColor(besserAlsBaseline > sortiertEintraege.count / 2 ? .green : .red)
                    Text("\(besserAlsBaseline) von \(sortiertEintraege.count) Nächten besser als dein Ausgangswert")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 4)
            }
        }
        .padding()
        .background(theme.karte)
        .cornerRadius(14)
        .padding(.horizontal)
    }
}

// MARK: - Balkendiagramm

struct BalkenAnsicht: View {
    @EnvironmentObject var theme: AppTheme
    var eintraege: [CheckInEintrag]
    var baselineWert: Double
    var cyan: Color

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 12) {
                LegendeItem(farbe: cyan, form: .rechteck, label: "Besser als Ausgangswert")
                LegendeItem(farbe: .red.opacity(0.6), form: .rechteck, label: "Schlechter")
                LegendeItem(farbe: .orange, form: .linie, label: "Ausgangswert")
            }

            GeometryReader { geo in
                let balkenBreite = (geo.size.width - 40) / CGFloat(eintraege.count)
                let maxHoehe = geo.size.height - 30

                ZStack(alignment: .bottomLeading) {
                    // Gitterlinien + Y-Achse
                    ForEach([2, 4, 6, 8, 10], id: \.self) { wert in
                        let y = maxHoehe - (maxHoehe * CGFloat(wert) / 10)
                        Path { p in
                            p.move(to: CGPoint(x: 30, y: y))
                            p.addLine(to: CGPoint(x: geo.size.width, y: y))
                        }
                        .stroke(Color.primary.opacity(0.08), lineWidth: 0.5)
                        Text("\(wert)")
                            .font(.system(size: 9))
                            .foregroundColor(.secondary)
                            .position(x: 14, y: y)
                    }

                    // Baseline
                    let baselineY = maxHoehe - (maxHoehe * CGFloat(baselineWert) / 10)
                    Path { p in
                        p.move(to: CGPoint(x: 30, y: baselineY))
                        p.addLine(to: CGPoint(x: geo.size.width, y: baselineY))
                    }
                    .stroke(Color.orange, style: StrokeStyle(lineWidth: 1.5, dash: [4, 4]))

                    // Balken
                    ForEach(Array(eintraege.enumerated()), id: \.offset) { index, eintrag in
                        let x = 30 + CGFloat(index) * balkenBreite
                        let balkenHoehe = maxHoehe * CGFloat(eintrag.schlafqualitaet) / 10
                        let y = maxHoehe - balkenHoehe
                        let istBesser = Double(eintrag.schlafqualitaet) >= baselineWert

                        RoundedRectangle(cornerRadius: 4)
                            .fill(istBesser ? cyan : Color.red.opacity(0.6))
                            .frame(width: max(balkenBreite - 4, 8), height: balkenHoehe)
                            .position(x: x + balkenBreite / 2, y: y + balkenHoehe / 2)

                        Text("\(eintrag.schlafqualitaet)")
                            .font(.system(size: 8))
                            .foregroundColor(.secondary)
                            .position(x: x + balkenBreite / 2, y: y - 8)

                        if index % 2 == 0 {
                            Text(kurzesDatum(eintrag.datum))
                                .font(.system(size: 8))
                                .foregroundColor(.secondary)
                                .position(x: x + balkenBreite / 2, y: maxHoehe + 16)
                        }
                    }
                }
            }
            .frame(height: 175)
        }
    }
}

// MARK: - Kurvendiagramm

struct KurvenAnsicht: View {
    var eintraege: [CheckInEintrag]
    var baselineWert: Double
    var cyan: Color

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 12) {
                LegendeItem(farbe: cyan, form: .linie, label: "Schlafqualität")
                LegendeItem(farbe: .orange, form: .linie, label: "Ausgangswert")
            }

            GeometryReader { geo in
                KurvenZeichnung(
                    eintraege: eintraege,
                    baselineWert: baselineWert,
                    cyan: cyan,
                    groesse: geo.size
                )
            }
            .frame(height: 175)
        }
    }
}

struct KurvenZeichnung: View {
    @EnvironmentObject var theme: AppTheme
    var eintraege: [CheckInEintrag]
    var baselineWert: Double
    var cyan: Color
    var groesse: CGSize

    let linksOffset: CGFloat = 30

    var maxHoehe: CGFloat { groesse.height - 30 }
    var nutzbreite: CGFloat { groesse.width - linksOffset }
    var n: Int { eintraege.count }

    func punkt(index: Int) -> CGPoint {
        let x = linksOffset + nutzbreite * CGFloat(index) / CGFloat(max(n - 1, 1))
        let y = maxHoehe - maxHoehe * CGFloat(eintraege[index].schlafqualitaet) / 10
        return CGPoint(x: x, y: y)
    }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Gitterlinien + Y-Achse
            ForEach([2, 4, 6, 8, 10], id: \.self) { wert in
                let y = maxHoehe - (maxHoehe * CGFloat(wert) / 10)
                Path { p in
                    p.move(to: CGPoint(x: linksOffset, y: y))
                    p.addLine(to: CGPoint(x: groesse.width, y: y))
                }
                .stroke(Color.primary.opacity(0.08), lineWidth: 0.5)
                Text("\(wert)")
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
                    .position(x: 14, y: y)
            }

            // Baseline
            Path { p in
                let y = maxHoehe - (maxHoehe * CGFloat(baselineWert) / 10)
                p.move(to: CGPoint(x: linksOffset, y: y))
                p.addLine(to: CGPoint(x: groesse.width, y: y))
            }
            .stroke(Color.orange, style: StrokeStyle(lineWidth: 1.5, dash: [4, 4]))

            if n > 1 {
                // Fläche unter der Kurve
                Path { p in
                    p.move(to: CGPoint(x: punkt(index: 0).x, y: maxHoehe))
                    p.addLine(to: punkt(index: 0))
                    for i in 1..<n {
                        let prev = punkt(index: i - 1)
                        let curr = punkt(index: i)
                        let midX = (prev.x + curr.x) / 2
                        p.addCurve(to: curr,
                                   control1: CGPoint(x: midX, y: prev.y),
                                   control2: CGPoint(x: midX, y: curr.y))
                    }
                    p.addLine(to: CGPoint(x: punkt(index: n - 1).x, y: maxHoehe))
                    p.closeSubpath()
                }
                .fill(LinearGradient(
                    colors: [cyan.opacity(0.25), cyan.opacity(0.0)],
                    startPoint: .top, endPoint: .bottom
                ))

                // Kurve
                Path { p in
                    p.move(to: punkt(index: 0))
                    for i in 1..<n {
                        let prev = punkt(index: i - 1)
                        let curr = punkt(index: i)
                        let midX = (prev.x + curr.x) / 2
                        p.addCurve(to: curr,
                                   control1: CGPoint(x: midX, y: prev.y),
                                   control2: CGPoint(x: midX, y: curr.y))
                    }
                }
                .stroke(cyan, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
            }

            // Punkte + Datumslabels
            ForEach(Array(eintraege.enumerated()), id: \.offset) { index, eintrag in
                let pt = punkt(index: index)
                let istBesser = Double(eintrag.schlafqualitaet) >= baselineWert
                Circle()
                    .fill(istBesser ? cyan : Color.red.opacity(0.8))
                    .frame(width: 8, height: 8)
                    .position(pt)
                if index % 2 == 0 {
                    Text(kurzesDatum(eintrag.datum))
                        .font(.system(size: 8))
                        .foregroundColor(.secondary)
                        .position(x: pt.x, y: maxHoehe + 16)
                }
            }
        }
    }
}

// MARK: - Hilfstypen

enum LegendeForm { case rechteck, linie }

struct LegendeItem: View {
    var farbe: Color
    var form: LegendeForm
    var label: String

    var body: some View {
        HStack(spacing: 6) {
            if form == .rechteck {
                RoundedRectangle(cornerRadius: 2).fill(farbe).frame(width: 12, height: 12)
            } else {
                Rectangle().fill(farbe).frame(width: 12, height: 2)
            }
            Text(label).font(.caption).foregroundColor(.secondary)
        }
    }
}

private func kurzesDatum(_ datum: Date) -> String {
    let f = DateFormatter()
    f.dateFormat = "dd.MM"
    return f.string(from: datum)
}

#Preview {
    ZStack {
        Color(red: 0.05, green: 0.11, blue: 0.24).ignoresSafeArea()
        SchlafGraphView(eintraege: [], baselineWert: 5.0)
            .environmentObject(AppTheme())
    }
}
