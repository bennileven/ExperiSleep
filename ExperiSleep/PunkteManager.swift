import Foundation
import Combine

class PunkteManager: ObservableObject {
    static let shared = PunkteManager()

    @Published var punkte: Int {
        didSet { UserDefaults.standard.set(punkte, forKey: "gesamtPunkte") }
    }

    init() {
        self.punkte = UserDefaults.standard.integer(forKey: "gesamtPunkte")
    }

    // +10 XP pro Check-in
    @discardableResult
    func checkIn() -> Int {
        let p = 10
        punkte += p
        sync()
        return p
    }

    // +50 XP für 7-Tage, +100 XP für 14-Tage Streak
    @discardableResult
    func streakMeilenstein(tage: Int) -> Int {
        let p = tage >= 14 ? 100 : 50
        punkte += p
        sync()
        return p
    }

    // +100 XP für abgeschlossenes Experiment
    @discardableResult
    func experimentAbgeschlossen() -> Int {
        let p = 100
        punkte += p
        sync()
        return p
    }

    func sync() {
        let name = UserDefaults.standard.string(forKey: "nutzername") ?? "Schläfer"
        let streak = UserDefaults.standard.integer(forKey: "letzterStreak")
        let experimente = UserDefaults.standard.integer(forKey: "abgeschlosseneExperimente")
        FirebaseManager.shared.profilAktualisieren(punkte: punkte, name: name, streak: streak, experimente: experimente)
    }
}
