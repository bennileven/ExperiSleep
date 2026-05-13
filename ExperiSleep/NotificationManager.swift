import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    private init() {}

    private let mittagsId = "checkin-mittag"
    private let abendsId  = "checkin-abend"

    func berechtigungAnfragen() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    // Beide Erinnerungen (neu) planen — ersetzt automatisch bestehende gleicher ID
    func erinnerungenPlanen() {
        planen(
            id: mittagsId,
            stunde: 12, minute: 0,
            titel: "Check-in Zeit 🌙",
            text: "Wie war deine letzte Nacht? Mach kurz deinen täglichen Check-in."
        )
        planen(
            id: abendsId,
            stunde: 21, minute: 0,
            titel: "Check-in vergessen? 😴",
            text: "Noch schnell den Check-in machen — dein Streak wartet!"
        )
    }

    // Alle Erinnerungen dauerhaft deaktivieren
    func alleDeaktivieren() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    // Wird aufgerufen sobald der Check-in heute erledigt ist
    func abendErinnerungDeaktivieren() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [abendsId])
    }

    private func planen(id: String, stunde: Int, minute: Int, titel: String, text: String) {
        let content = UNMutableNotificationContent()
        content.title = titel
        content.body  = text
        content.sound = .default

        var components    = DateComponents()
        components.hour   = stunde
        components.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}
