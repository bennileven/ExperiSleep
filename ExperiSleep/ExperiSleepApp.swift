import SwiftUI
import FirebaseCore

@main
struct ExperiSleepApp: App {
    @AppStorage("onboardingAbgeschlossen") var onboardingAbgeschlossen = false
    @StateObject private var aktiveExperimente = AktiveExperimente()
    @StateObject private var speicher = CheckInSpeicher()
    
    @AppStorage("mitteilungenAktiv") var mitteilungenAktiv = true

    init() {
        FirebaseApp.configure()
        NotificationManager.shared.berechtigungAnfragen()
        if UserDefaults.standard.object(forKey: "mitteilungenAktiv") == nil || UserDefaults.standard.bool(forKey: "mitteilungenAktiv") {
            NotificationManager.shared.erinnerungenPlanen()
        }
    }
    
    var body: some Scene {
        WindowGroup {
            if onboardingAbgeschlossen {
                ContentView()
                    .environmentObject(aktiveExperimente)
                    .environmentObject(speicher)
            } else {
                OnboardingView()
                    .environmentObject(aktiveExperimente)
                    .environmentObject(speicher)
            }
        }
    }
}
