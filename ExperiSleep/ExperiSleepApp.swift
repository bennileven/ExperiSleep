import SwiftUI
import FirebaseCore

@main
struct ExperiSleepApp: App {
    @AppStorage("onboardingAbgeschlossen") var onboardingAbgeschlossen = false
    @StateObject private var aktiveExperimente = AktiveExperimente()
    @StateObject private var speicher = CheckInSpeicher()
    
    init() {
        FirebaseApp.configure()
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
