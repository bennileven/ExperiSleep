import Foundation
import Combine
import HealthKit

class HealthKitManager: ObservableObject {
    static let shared = HealthKitManager()
    let healthStore = HKHealthStore()
    
    func berechtigungAnfragen(completion: @escaping (Bool) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false)
            return
        }
        
        let leseTypen: Set<HKObjectType> = [
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!
        ]
        
        healthStore.requestAuthorization(toShare: nil, read: leseTypen) { erfolg, error in
            DispatchQueue.main.async {
                completion(erfolg)
            }
        }
    }
    
    // Schlafdaten einer bestimmten Nacht laden
    func schlafdatenLaden(completion: @escaping (Double, Int) -> Void) {
        schlafdatenFuerNacht(datum: Date(), completion: completion)
    }
    
    // Schlafdaten für eine bestimmte Nacht laden
    func schlafdatenFuerNacht(datum: Date, completion: @escaping (Double, Int) -> Void) {
        let schlafTyp = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!

        let nachtEnde = Calendar.current.startOfDay(for: datum).addingTimeInterval(12 * 3600)
        let nachtStart = nachtEnde.addingTimeInterval(-14 * 3600)

        let predikat = HKQuery.predicateForSamples(
            withStart: nachtStart,
            end: nachtEnde,
            options: .strictStartDate
        )

        let query = HKSampleQuery(
            sampleType: schlafTyp,
            predicate: predikat,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: nil
        ) { _, ergebnisse, _ in
            guard let samples = ergebnisse as? [HKCategorySample], !samples.isEmpty else {
                completion(0, 5)
                return
            }

            func sekunden(_ phasen: [HKCategorySample]) -> Double {
                phasen.reduce(0) { $0 + $1.endDate.timeIntervalSince($1.startDate) }
            }

            let tiefSek  = sekunden(samples.filter { $0.value == HKCategoryValueSleepAnalysis.asleepDeep.rawValue })
            let remSek   = sekunden(samples.filter { $0.value == HKCategoryValueSleepAnalysis.asleepREM.rawValue })
            let kernSek  = sekunden(samples.filter { $0.value == HKCategoryValueSleepAnalysis.asleepCore.rawValue })
            let wachSek  = sekunden(samples.filter { $0.value == HKCategoryValueSleepAnalysis.awake.rawValue })
            let asleepSek = sekunden(samples.filter { $0.value == HKCategoryValueSleepAnalysis.asleep.rawValue })

            // Ältere Geräte ohne Phasendaten nutzen nur .asleep
            let hatPhasendaten = (tiefSek + remSek + kernSek) > 0
            let schlafSek = hatPhasendaten ? (tiefSek + remSek + kernSek) : asleepSek
            let stunden = schlafSek / 3600

            guard stunden > 0 else {
                completion(0, 1)
                return
            }

            // Dauer-Basispunkte (1–7)
            let dauerScore: Int
            if stunden < 4      { dauerScore = 1 }
            else if stunden < 5 { dauerScore = 2 }
            else if stunden < 6 { dauerScore = 3 }
            else if stunden < 7 { dauerScore = 5 }
            else if stunden < 9 { dauerScore = 7 }
            else                { dauerScore = 6 }

            var score: Int

            if hatPhasendaten {
                let tiefAnteil = tiefSek / schlafSek
                let remAnteil  = remSek  / schlafSek
                let wachAnteil = (schlafSek + wachSek) > 0 ? wachSek / (schlafSek + wachSek) : 0

                // Tiefschlaf-Bonus/Abzug (-1 bis +2)
                let tiefBonus: Int
                if tiefAnteil >= 0.17 && tiefAnteil <= 0.33 {
                    tiefBonus = 2
                } else if (tiefAnteil >= 0.12 && tiefAnteil < 0.17) || (tiefAnteil > 0.33 && tiefAnteil <= 0.38) {
                    tiefBonus = 1
                } else if tiefAnteil < 0.08 {
                    tiefBonus = -1
                } else {
                    tiefBonus = 0
                }

                // REM-Bonus/Abzug (-1 bis +2)
                let remBonus: Int
                if remAnteil >= 0.18 && remAnteil <= 0.34 {
                    remBonus = 2
                } else if (remAnteil >= 0.12 && remAnteil < 0.18) || (remAnteil > 0.34 && remAnteil <= 0.40) {
                    remBonus = 1
                } else if remAnteil < 0.08 {
                    remBonus = -1
                } else {
                    remBonus = 0
                }

                // Wachphasen-Abzug (0 oder -1)
                let wachAbzug = wachAnteil > 0.20 ? -1 : 0

                score = dauerScore + tiefBonus + remBonus + wachAbzug
            } else {
                score = dauerScore
            }

            // Unter 4 Stunden → maximal 4/10
            if stunden < 4 { score = min(score, 4) }

            let qualitaet = max(1, min(10, score))

            DispatchQueue.main.async {
                completion(stunden, qualitaet)
            }
        }

        healthStore.execute(query)
    }
    
    // Durchschnittliche Schlafqualität der letzten N Nächte aus HealthKit
    func schlafdurchschnittLetzteNaechte(anzahl: Int, completion: @escaping (Double?) -> Void) {
        let gruppe = DispatchGroup()
        var qualitaeten: [Int] = []

        for i in 1...anzahl {
            guard let datum = Calendar.current.date(byAdding: .day, value: -i, to: Date()) else { continue }
            gruppe.enter()
            schlafdatenFuerNacht(datum: datum) { stunden, qualitaet in
                if stunden > 0 { qualitaeten.append(qualitaet) }
                gruppe.leave()
            }
        }

        gruppe.notify(queue: .main) {
            guard !qualitaeten.isEmpty else { completion(nil); return }
            completion(Double(qualitaeten.reduce(0, +)) / Double(qualitaeten.count))
        }
    }

    // Letzte N Nächte aus Apple Health importieren
    func vergangeneNaechteImportieren(anzahl: Int, experimentTitel: String, speicher: CheckInSpeicher, completion: @escaping (Int) -> Void) {
        let gruppe = DispatchGroup()
        var importiert = 0
        
        for i in 1...anzahl {
            guard let datum = Calendar.current.date(byAdding: .day, value: -i, to: Date()) else { continue }
            let zielTag = Calendar.current.startOfDay(for: datum)
            
            // Prüfen ob für diesen Tag schon ein Eintrag existiert
            let existiert = speicher.eintraege.contains {
                Calendar.current.startOfDay(for: $0.datum) == zielTag
            }
            
            if existiert { continue }
            
            gruppe.enter()
            schlafdatenFuerNacht(datum: datum) { stunden, qualitaet in
                if stunden > 0 {
                    let eintrag = CheckInEintrag(
                        datum: zielTag.addingTimeInterval(8 * 3600), // 8 Uhr morgens
                        schlafqualitaet: qualitaet,
                        energie: 5,
                        stress: 5,
                        experimentTitel: experimentTitel,
                        istBaseline: false
                    )
                    DispatchQueue.main.async {
                        speicher.speichern(eintrag: eintrag)
                        FirebaseManager.shared.checkInSpeichern(eintrag: eintrag)
                        importiert += 1
                    }
                }
                gruppe.leave()
            }
        }
        
        gruppe.notify(queue: .main) {
            completion(importiert)
        }
    }
}
