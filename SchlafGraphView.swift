import SwiftUI

struct SchlafGraphView: View {
    var eintraege: [CheckInEintrag]
    var baselineWert: Double
    
    let cyan = Color(red: 0.0, green: 0.90, blue: 0.80)
    
    var sortiertEintraege: [CheckInEintrag] {
        Array(eintraege.sorted { $0.datum < $1.datum }.suffix(14))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            Text("Schlafverlauf")
                .font(.headline)
                .foregroundColor(.white.opacity(0.7))
            
            if sortiertEintraege.isEmpty {
                Text("Noch keine Daten vorhanden")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.4))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                
                // Legende
                HStack(spacing: 12) {
                    HStack(spacing: 6) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(cyan)
                            .frame(width: 12, height: 12)
                        Text("Besser als Ausgangswert")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }
                    HStack(spacing: 6) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.red.opacity(0.6))
                            .frame(width: 12, height: 12)
                        Text("Schlechter")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }
                    HStack(spacing: 6) {
                        Rectangle()
                            .fill(Color.orange)
                            .frame(width: 12, height: 2)
                        Text("Ausgangswert")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                
                // Graph
                GeometryReader { geo in
                    let balkenBreite = (geo.size.width - 40) / CGFloat(sortiertEintraege.count)
                    let maxHoehe = geo.size.height - 40
                    
                    ZStack(alignment: .bottomLeading) {
                        
                        // Hintergrund Linien
                        ForEach([2, 4, 6, 8, 10], id: \.self) { wert in
                            let y = maxHoehe - (maxHoehe * CGFloat(wert) / 10)
                            Path { path in
                                path.move(to: CGPoint(x: 30, y: y))
                                path.addLine(to: CGPoint(x: geo.size.width, y: y))
                            }
                            .stroke(Color.white.opacity(0.08), lineWidth: 0.5)
                            
                            Text("\(wert)")
                                .font(.system(size: 9))
                                .foregroundColor(.white.opacity(0.3))
                                .position(x: 14, y: y)
                        }
                        
                        // Baseline Linie
                        let baselineY = maxHoehe - (maxHoehe * CGFloat(baselineWert) / 10)
                        Path { path in
                            path.move(to: CGPoint(x: 30, y: baselineY))
                            path.addLine(to: CGPoint(x: geo.size.width, y: baselineY))
                        }
                        .stroke(Color.orange, style: StrokeStyle(lineWidth: 1.5, dash: [4, 4]))
                        
                        // Balken
                        ForEach(Array(sortiertEintraege.enumerated()), id: \.offset) { index, eintrag in
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
                                .foregroundColor(.white.opacity(0.7))
                                .position(x: x + balkenBreite / 2, y: y - 8)
                            
                            if index % 2 == 0 {
                                Text(kurzesDatum(datum: eintrag.datum))
                                    .font(.system(size: 8))
                                    .foregroundColor(.white.opacity(0.4))
                                    .position(x: x + balkenBreite / 2, y: maxHoehe + 16)
                            }
                        }
                        
                        // Trendlinie
                        if sortiertEintraege.count > 1 {
                            Path { path in
                                for (index, eintrag) in sortiertEintraege.enumerated() {
                                    let x = 30 + CGFloat(index) * balkenBreite + balkenBreite / 2
                                    let y = maxHoehe - (maxHoehe * CGFloat(eintrag.schlafqualitaet) / 10)
                                    if index == 0 {
                                        path.move(to: CGPoint(x: x, y: y))
                                    } else {
                                        path.addLine(to: CGPoint(x: x, y: y))
                                    }
                                }
                            }
                            .stroke(Color.white.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [2, 2]))
                        }
                    }
                }
                .frame(height: 200)
                
                // Zusammenfassung
                let besserAlsBaseline = sortiertEintraege.filter {
                    Double($0.schlafqualitaet) >= baselineWert
                }.count
                
                HStack(spacing: 8) {
                    Image(systemName: besserAlsBaseline > sortiertEintraege.count / 2 ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                        .foregroundColor(besserAlsBaseline > sortiertEintraege.count / 2 ? .green : .red)
                    Text("\(besserAlsBaseline) von \(sortiertEintraege.count) Nächten besser als dein Ausgangswert")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.top, 4)
            }
        }
        .padding()
        .background(Color.white.opacity(0.06))
        .cornerRadius(14)
        .padding(.horizontal)
    }
    
    func kurzesDatum(datum: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM"
        return formatter.string(from: datum)
    }
}

#Preview {
    ZStack {
        Color(red: 0.05, green: 0.11, blue: 0.24).ignoresSafeArea()
        SchlafGraphView(eintraege: [], baselineWert: 5.0)
    }
}
