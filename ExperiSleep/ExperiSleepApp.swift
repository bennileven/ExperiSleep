import SwiftUI
import FirebaseCore

@main
struct ExperiSleepApp: App {
    @AppStorage("onboardingAbgeschlossen") var onboardingAbgeschlossen = false
    @StateObject private var aktiveExperimente = AktiveExperimente()
    @StateObject private var speicher = CheckInSpeicher()
    @StateObject private var theme = AppTheme()
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
            RootView(splashFertig: $splashFertig)
                .environmentObject(aktiveExperimente)
                .environmentObject(speicher)
                .environmentObject(theme)
        }
        .onChange(of: scenePhase) { phase in
            if phase == .active {
                aktiveExperimente.pruefeAbgelaufene()
            }
        }
    }
}

struct RootView: View {
    @Binding var splashFertig: Bool
    @AppStorage("onboardingAbgeschlossen") var onboardingAbgeschlossen = false
    @EnvironmentObject var theme: AppTheme
    @EnvironmentObject var aktiveExperimente: AktiveExperimente
    @EnvironmentObject var speicher: CheckInSpeicher

    var body: some View {
        Group {
            if !splashFertig {
                SplashView(onFinished: { splashFertig = true })
            } else if onboardingAbgeschlossen {
                ContentView()
            } else {
                OnboardingView()
            }
        }
        .preferredColorScheme(theme.schema)
    }
}
