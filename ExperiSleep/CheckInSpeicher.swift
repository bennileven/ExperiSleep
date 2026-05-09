import Foundation
import Combine

struct CheckInEintrag: Codable, Identifiable {
    var id = UUID()
    var datum: Date
    var schlafqualitaet: Int
    var energie: Int
    var stress: Int
    var experimentTitel: String
    var istBaseline: Bool
}

class CheckInSpeicher: ObservableObject {
    @Published var eintraege: [CheckInEintrag] = []
    
    private let schluessel = "checkins"
    
    init() {
        laden()
    }
    
    func speichern(eintrag: CheckInEintrag) {
        eintraege.append(eintrag)
        sichern()
    }
    
    func loeschen(wo bedingung: @escaping (CheckInEintrag) -> Bool) {
        eintraege.removeAll(where: bedingung)
        sichern()
    }
    
    func eintraegeFor(experiment: String) -> [CheckInEintrag] {
        return eintraege.filter { $0.experimentTitel == experiment }
    }
    
    func durchschnittSchlaf(experiment: String, baseline: Bool) -> Double {
        let gefiltert = eintraege.filter {
            $0.experimentTitel == experiment && $0.istBaseline == baseline
        }
        guard !gefiltert.isEmpty else { return 0 }
        let summe = gefiltert.reduce(0) { $0 + $1.schlafqualitaet }
        return Double(summe) / Double(gefiltert.count)
    }
    
    private func sichern() {
        if let data = try? JSONEncoder().encode(eintraege) {
            UserDefaults.standard.set(data, forKey: schluessel)
        }
    }
    
    private func laden() {
        if let data = UserDefaults.standard.data(forKey: schluessel),
           let gespeichert = try? JSONDecoder().decode([CheckInEintrag].self, from: data) {
            eintraege = gespeichert
        }
    }
}
