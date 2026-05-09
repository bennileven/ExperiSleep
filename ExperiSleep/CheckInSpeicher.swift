//
//  CheckInSpeicher.swift
//  ExperiSleep
//
//  Created by benni leven on 07.05.26.
//

import Foundation
import Combine

// Datenmodell für einen Check-in
struct CheckInEintrag: Codable, Identifiable {
    var id = UUID()
    var datum: Date
    var schlafqualitaet: Int
    var energie: Int
    var stress: Int
    var experimentTitel: String
    var istBaseline: Bool  // true = Woche 1, false = Woche 2
}

// Speichern und Laden der Check-ins
class CheckInSpeicher: ObservableObject {
    @Published var eintraege: [CheckInEintrag] = []
    
    private let schluessel = "checkins"
    
    init() {
        laden()
    }
    
    // Neuen Check-in speichern
    func speichern(eintrag: CheckInEintrag) {
        eintraege.append(eintrag)
        sichern()
    }
    
    // Alle Check-ins für ein Experiment holen
    func eintraegeFor(experiment: String) -> [CheckInEintrag] {
        return eintraege.filter { $0.experimentTitel == experiment }
    }
    
    // Durchschnitt berechnen
    func durchschnittSchlaf(experiment: String, baseline: Bool) -> Double {
        let gefiltert = eintraege.filter {
            $0.experimentTitel == experiment && $0.istBaseline == baseline
        }
        guard !gefiltert.isEmpty else { return 0 }
        let summe = gefiltert.reduce(0) { $0 + $1.schlafqualitaet }
        return Double(summe) / Double(gefiltert.count)
    }
    
    // Intern: auf dem Gerät sichern
    private func sichern() {
        if let data = try? JSONEncoder().encode(eintraege) {
            UserDefaults.standard.set(data, forKey: schluessel)
        }
    }
    
    // Intern: vom Gerät laden
    private func laden() {
        if let data = UserDefaults.standard.data(forKey: schluessel),
           let gespeichert = try? JSONDecoder().decode([CheckInEintrag].self, from: data) {
            eintraege = gespeichert
        }
    }
}
