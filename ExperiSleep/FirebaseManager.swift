import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

class FirebaseManager: ObservableObject {
    static let shared = FirebaseManager()

    @Published var nutzerID: String = ""
    @Published var istAngemeldet: Bool = false

    private let db = Firestore.firestore()
    private var warteschlange: [CheckInEintrag] = []

    init() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }
            let eingeloggt = user != nil && user?.isAnonymous == false
            DispatchQueue.main.async {
                self.nutzerID = eingeloggt ? (user?.uid ?? "") : ""
                self.istAngemeldet = eingeloggt
                if eingeloggt {
                    for eintrag in self.warteschlange {
                        self.checkInSpeichernDirekt(eintrag: eintrag)
                    }
                    self.warteschlange.removeAll()
                }
            }
        }
    }

    // MARK: - Auth

    func registrieren(email: String, passwort: String, completion: @escaping (String?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: passwort) { _, error in
            DispatchQueue.main.async {
                completion(error.map { self.fehlermeldung($0) })
            }
        }
    }

    func einloggen(email: String, passwort: String, completion: @escaping (String?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: passwort) { _, error in
            DispatchQueue.main.async {
                completion(error.map { self.fehlermeldung($0) })
            }
        }
    }

    func abmelden() {
        try? Auth.auth().signOut()
    }

    private func fehlermeldung(_ error: Error) -> String {
        switch AuthErrorCode(rawValue: (error as NSError).code) {
        case .emailAlreadyInUse:  return "Diese E-Mail ist bereits registriert."
        case .invalidEmail:       return "Ungültige E-Mail-Adresse."
        case .weakPassword:       return "Passwort zu schwach (mind. 6 Zeichen)."
        case .wrongPassword:      return "Falsches Passwort."
        case .userNotFound:       return "Kein Konto mit dieser E-Mail gefunden."
        default:                  return "Fehler: \(error.localizedDescription)"
        }
    }

    // MARK: - Daten

    func checkInSpeichern(eintrag: CheckInEintrag) {
        if nutzerID.isEmpty {
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
                if let error = error { print("❌ \(error)") }
            }
    }

    func profilAktualisieren(punkte: Int, name: String, streak: Int, experimente: Int, oeffentlich: Bool) {
        guard !nutzerID.isEmpty else { return }
        let data: [String: Any] = [
            "anzeigeName": name.isEmpty ? "Anonymer Nutzer" : name,
            "punkte": punkte,
            "streak": streak,
            "experimente": experimente,
            "zuletzt": Date(),
            "oeffentlich": oeffentlich
        ]
        db.collection("nutzer_profile").document(nutzerID).setData(data, merge: true)
    }

    func ranglisteLaden(completion: @escaping ([RanglisteEintrag]) -> Void) {
        db.collection("nutzer_profile")
            .order(by: "punkte", descending: true)
            .limit(to: 50)
            .getDocuments { snapshot, _ in
                guard let docs = snapshot?.documents else { completion([]); return }
                let eintraege = docs.compactMap { doc -> RanglisteEintrag? in
                    let data = doc.data()
                    guard data["oeffentlich"] as? Bool == true else { return nil }
                    return RanglisteEintrag(
                        id: doc.documentID,
                        anzeigeName: data["anzeigeName"] as? String ?? "Anonymer Nutzer",
                        punkte: data["punkte"] as? Int ?? 0,
                        streak: data["streak"] as? Int ?? 0,
                        experimente: data["experimente"] as? Int ?? 0
                    )
                }
                completion(eintraege)
            }
    }
}

struct RanglisteEintrag: Identifiable {
    var id: String
    var anzeigeName: String
    var punkte: Int
    var streak: Int
    var experimente: Int
}
