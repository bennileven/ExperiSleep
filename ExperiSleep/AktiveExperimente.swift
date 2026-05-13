import Foundation
import Combine

struct AktivesExperiment: Codable {
    var titel: String
    var startDatum: Date
}

struct AbgeschlossenesExperiment: Codable, Identifiable {
    var id = UUID()
    var titel: String
    var startDatum: Date
    var endDatum: Date

    var dauerInTagen: Int {
        max(1, Calendar.current.dateComponents([.day], from: startDatum, to: endDatum).day ?? 1)
    }
}

class AktiveExperimente: ObservableObject {
    @Published var aktive: [AktivesExperiment] = []
    @Published var vergangene: [AbgeschlossenesExperiment] = []
    @Published var neuAbgeschlossen: AbgeschlossenesExperiment? = nil

    private let aktivSchluessel    = "aktiveExperimente"
    private let verlaufSchluessel  = "vergangeneExperimente"

    init() {
        laden()
        pruefeAbgelaufene()
    }

    func pruefeAbgelaufene() {
        let abgelaufen = aktive.filter {
            let tage = Calendar.current.dateComponents([.day], from: $0.startDatum, to: Date()).day ?? 0
            return tage >= 14
        }
        for experiment in abgelaufen {
            let abgeschlossen = AbgeschlossenesExperiment(
                titel: experiment.titel,
                startDatum: experiment.startDatum,
                endDatum: experiment.startDatum.addingTimeInterval(14 * 24 * 3600)
            )
            vergangene.insert(abgeschlossen, at: 0)
        }
        if !abgelaufen.isEmpty {
            aktive.removeAll { exp in abgelaufen.contains { $0.titel == exp.titel } }
            sichern()
            sichernVerlauf()
            neuAbgeschlossen = vergangene.first
        }
    }

    func starten(titel: String) {
        if !aktive.contains(where: { $0.titel == titel }) {
            aktive.append(AktivesExperiment(titel: titel, startDatum: Date()))
            sichern()
        }
    }

    func stoppen(titel: String) {
        if let experiment = aktive.first(where: { $0.titel == titel }) {
            let abgeschlossen = AbgeschlossenesExperiment(
                titel: experiment.titel,
                startDatum: experiment.startDatum,
                endDatum: Date()
            )
            vergangene.insert(abgeschlossen, at: 0)
            sichernVerlauf()
        }
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
            UserDefaults.standard.set(data, forKey: aktivSchluessel)
        }
    }

    private func sichernVerlauf() {
        if let data = try? JSONEncoder().encode(vergangene) {
            UserDefaults.standard.set(data, forKey: verlaufSchluessel)
        }
    }

    private func laden() {
        if let data = UserDefaults.standard.data(forKey: aktivSchluessel),
           let gespeichert = try? JSONDecoder().decode([AktivesExperiment].self, from: data) {
            aktive = gespeichert
        }
        if let data = UserDefaults.standard.data(forKey: verlaufSchluessel),
           let gespeichert = try? JSONDecoder().decode([AbgeschlossenesExperiment].self, from: data) {
            vergangene = gespeichert
        }
    }
}
