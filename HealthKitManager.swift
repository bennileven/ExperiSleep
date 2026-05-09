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
            guard let samples = ergebnisse as? [HKCategorySample] else {
                completion(0, 5)
                return
            }
            
            let tiefSchlaf = samples.filter {
                $0.value == HKCategoryValueSleepAnalysis.asleepDeep.rawValue ||
                $0.value == HKCategoryValueSleepAnalysis.asleepREM.rawValue ||
                $0.value == HKCategoryValueSleepAnalysis.asleepCore.rawValue
            }
            
            let gesamtSekunden = tiefSchlaf.reduce(0) { $0 + $1.endDate.timeIntervalSince($1.startDate) }
            let stunden = gesamtSekunden / 3600
            
            let qualitaet: Int
            switch stunden {
            case 0..<4: qualitaet = 2
            case 4..<5: qualitaet = 4
            case 5..<6: qualitaet = 5
            case 6..<7: qualitaet = 6
            case 7..<8: qualitaet = 8
            default: qualitaet = 9
            }
            
            DispatchQueue.main.async {
                completion(stunden, qualitaet)
            }
        }
        
        healthStore.execute(query)
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
