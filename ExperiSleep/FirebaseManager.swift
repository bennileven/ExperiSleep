import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

class FirebaseManager: ObservableObject {
    static let shared = FirebaseManager()
    
    @Published var nutzerID: String = ""
    private let db = Firestore.firestore()
    private var warteschlange: [CheckInEintrag] = []
    
    init() {
        anmelden()
    }
    
    func anmelden() {
        Auth.auth().signInAnonymously { result, error in
            if let error = error {
                print("❌ Login Fehler: \(error)")
                return
            }
            self.nutzerID = result?.user.uid ?? ""
            print("✅ Angemeldet als: \(self.nutzerID)")
            
            // Warteschlange abarbeiten
            for eintrag in self.warteschlange {
                self.checkInSpeichernDirekt(eintrag: eintrag)
            }
            self.warteschlange.removeAll()
        }
    }
    
    func checkInSpeichern(eintrag: CheckInEintrag) {
        print("🔄 Versuche zu speichern... NutzerID: \(nutzerID)")
        
        if nutzerID.isEmpty {
            print("⏳ Noch nicht angemeldet — in Warteschlange")
            warteschlange.append(eintrag)
        } else {
            checkInSpeichernDirekt(eintrag: eintrag)
        }
    }
    
    private func checkInSpeichernDirekt(eintrag: CheckInEintrag) {
        let data: [String: Any] = [
            "datum": eintrag.datum,
            "schlafqualitaet": eintrag.schlafqualitaet,
            "energie": eintrag.energie,
            "stress": eintrag.stress,
            "experimentTitel": eintrag.experimentTitel,
            "istBaseline": eintrag.istBaseline,
            "nutzerID": nutzerID
        ]
        
        db.collection("checkins")
            .document(eintrag.id.uuidString)
            .setData(data) { error in
                if let error = error {
                    print("❌ Fehler beim Speichern: \(error)")
                } else {
                    print("✅ CheckIn erfolgreich in Firebase gespeichert!")
                }
            }
    }
    
    func ranglisteLaden(completion: @escaping ([RanglisteEintrag]) -> Void) {
        db.collection("streak_scores")
            .order(by: "streak", descending: true)
            .limit(to: 20)
            .getDocuments { snapshot, error in
                guard let docs = snapshot?.documents else { return }
                
                let eintraege = docs.compactMap { doc -> RanglisteEintrag? in
                    let data = doc.data()
                    return RanglisteEintrag(
                        id: doc.documentID,
                        anzeigeName: data["anzeigeName"] as? String ?? "Nutzer",
                        streak: data["streak"] as? Int ?? 0,
                        experimente: data["experimente"] as? Int ?? 0
                    )
                }
                completion(eintraege)
            }
    }
    
    func streakHochladen(streak: Int, experimente: Int) {
        guard !nutzerID.isEmpty else { return }
        
        let data: [String: Any] = [
            "anzeigeName": "Nutzer \(String(nutzerID.prefix(4)))",
            "streak": streak,
            "experimente": experimente,
            "zuletzt": Date()
        ]
        
        db.collection("streak_scores")
            .document(nutzerID)
            .setData(data)
    }
}

struct RanglisteEintrag: Identifiable {
    var id: String
    var anzeigeName: String
    var streak: Int
    var experimente: Int
}
