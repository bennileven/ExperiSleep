import Foundation
import Combine

struct AktivesExperiment: Codable {
    var titel: String
    var startDatum: Date
}

class AktiveExperimente: ObservableObject {
    @Published var aktive: [AktivesExperiment] = []
    
    private let schluessel = "aktiveExperimente"
    
    init() { laden() }
    
    func starten(titel: String) {
        if !aktive.contains(where: { $0.titel == titel }) {
            let neues = AktivesExperiment(titel: titel, startDatum: Date())
            aktive.append(neues)
            sichern()
        }
    }
    
    func stoppen(titel: String) {
        aktive.removeAll { $0.titel == titel }
        sichern()
    }
    
    func istAktiv(titel: String) -> Bool {
        aktive.contains { $0.titel == titel }
    }
    
    func startDatum(fuer titel: String) -> Date? {
        aktive.first { $0.titel == titel }?.startDatum
    }
    
    func wocheDesExperiments(fuer titel: String) -> Int {
        guard let start = startDatum(fuer: titel) else { return 1 }
        let tage = Calendar.current.dateComponents([.day], from: start, to: Date()).day ?? 0
        return tage < 7 ? 1 : 2
    }
    
    var aktiveNamen: [String] {
        aktive.map { $0.titel }
    }
    
    private func sichern() {
        if let data = try? JSONEncoder().encode(aktive) {
            UserDefaults.standard.set(data, forKey: schluessel)
        }
    }
    
    private func laden() {
        if let data = UserDefaults.standard.data(forKey: schluessel),
           let gespeichert = try? JSONDecoder().decode([AktivesExperiment].self, from: data) {
            aktive = gespeichert
        }
    }
}
