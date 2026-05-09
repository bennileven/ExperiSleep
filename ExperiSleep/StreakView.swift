import SwiftUI
import Combine

struct StreakView: View {
    var experimentTitel: String
    @StateObject private var speicher = CheckInSpeicher()
    
    var streak: Int {
        let eintraege = speicher.eintraegeFor(experiment: experimentTitel)
            .sorted { $0.datum > $1.datum }
        
        guard !eintraege.isEmpty else { return 0 }
        
        var count = 0
        var pruefdatum = Calendar.current.startOfDay(for: Date())
        
        for eintrag in eintraege {
            let eintragTag = Calendar.current.startOfDay(for: eintrag.datum)
            if eintragTag == pruefdatum {
                count += 1
                pruefdatum = Calendar.current.date(byAdding: .day, value: -1, to: pruefdatum)!
            } else {
                break
            }
        }
        return count
    }
    
    var maxStreak: Int { 14 }
    
    var streakEmoji: String {
        switch streak {
        case 0: return "😴"
        case 1...3: return "🌱"
        case 4...7: return "🔥"
        case 8...13: return "⚡"
        default: return "🏆"
        }
    }
    
    var body: some View {
        VStack(spacing: 25) {
            
            VStack(spacing: 10) {
                Text(streakEmoji)
                    .font(.system(size: 60))
                
                Text("\(streak)")
                    .font(.system(size: 80, weight: .bold))
                    .foregroundColor(streak >= 7 ? .orange : .indigo)
                
                Text(streak == 1 ? "Tag in Folge" : "Tage in Folge")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 20)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Fortschritt")
                        .font(.subheadline)
                        .bold()
                    Spacer()
                    Text("\(streak) / \(maxStreak) Tage")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 16)
                        
                        RoundedRectangle(cornerRadius: 8)
                            .fill(streak >= 7 ? Color.orange : Color.indigo)
                            .frame(width: geo.size.width * CGFloat(streak) / CGFloat(maxStreak), height: 16)
                    }
                }
                .frame(height: 16)
            }
            .padding()
            .background(Color.gray.opacity(0.15))
            .cornerRadius(12)
            .padding(.horizontal)
            
            VStack(spacing: 12) {
                Text("Die letzten 14 Tage")
                    .font(.headline)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                    ForEach(0..<14) { tag in
                        let hatEintrag = hatEintragFuerTag(tag: tag)
                        Circle()
                            .fill(hatEintrag ? Color.indigo : Color.gray.opacity(0.2))
                            .frame(width: 36, height: 36)
                            .overlay(
                                Text(tagNummer(tag: tag))
                                    .font(.caption2)
                                    .foregroundColor(hatEintrag ? .white : .secondary)
                            )
                    }
                }
            }
            .padding()
            .background(Color.gray.opacity(0.15))
            .cornerRadius(12)
            .padding(.horizontal)
            
            Text(motivationsText())
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
            
            Spacer()
        }
        .navigationTitle("Streak")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
    
    func hatEintragFuerTag(tag: Int) -> Bool {
        let zieldatum = Calendar.current.date(byAdding: .day, value: -(13 - tag), to: Date())!
        let zielTag = Calendar.current.startOfDay(for: zieldatum)
        return speicher.eintraegeFor(experiment: experimentTitel).contains {
            Calendar.current.startOfDay(for: $0.datum) == zielTag
        }
    }
    
    func tagNummer(tag: Int) -> String {
        let datum = Calendar.current.date(byAdding: .day, value: -(13 - tag), to: Date())!
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: datum)
    }
    
    func motivationsText() -> String {
        switch streak {
        case 0: return "Starte heute deinen ersten Check-in!"
        case 1...3: return "Guter Start! Bleib dran."
        case 4...6: return "Du bist auf einem guten Weg 🔥"
        case 7: return "Eine Woche geschafft! Halbzeit 💪"
        case 8...13: return "Fast am Ziel — gib nicht auf!"
        default: return "Experiment abgeschlossen! Schau dir deine Auswertung an 🏆"
        }
    }
}

#Preview {
    NavigationView {
        StreakView(experimentTitel: "Kein Koffein nach 14 Uhr")
    }
}
