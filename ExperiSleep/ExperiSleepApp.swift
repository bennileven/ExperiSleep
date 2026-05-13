import SwiftUI
import FirebaseCore

@main
struct ExperiSleepApp: App {
    @AppStorage("onboardingAbgeschlossen") var onboardingAbgeschlossen = false
    @StateObject private var aktiveExperimente = AktiveExperimente()
    @StateObject private var speicher = CheckInSpeicher()
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("mitteilungenAktiv") var mitteilungenAktiv = true
    @State private var splashFertig = false

    init() {
        FirebaseApp.configure()
        NotificationManager.shared.berechtigungAnfragen()
        if UserDefaults.standard.object(forKey: "mitteilungenAktiv") == nil || UserDefaults.standard.bool(forKey: "mitteilungenAktiv") {
            NotificationManager.shared.erinnerungenPlanen()
        }
    }
    
    var body: some Scene {
        WindowGroup {
            if !splashFertig {
                SplashView(onFinished: { splashFertig = true })
            } else if onboardingAbgeschlossen {
                ContentView()
                    .environmentObject(aktiveExperimente)
                    .environmentObject(speicher)
            } else {
                OnboardingView()
                    .environmentObject(aktiveExperimente)
                    .environmentObject(speicher)
            }
        }
        .onChange(of: scenePhase) { phase in
            if phase == .active {
                aktiveExperimente.pruefeAbgelaufene()
            }
        }
    }
}
