import SwiftUI
import Combine

class AppTheme: ObservableObject {
    @Published var istHell: Bool {
        didSet { UserDefaults.standard.set(istHell, forKey: "hellModus") }
    }

    init() {
        self.istHell = UserDefaults.standard.bool(forKey: "hellModus")
    }

    var hintergrund: Color {
        istHell ? Color(.systemGroupedBackground) : Color(red: 0.05, green: 0.11, blue: 0.24)
    }
    var karte: Color {
        istHell ? Color(.secondarySystemGroupedBackground) : Color.white.opacity(0.06)
    }
    var schema: ColorScheme {
        istHell ? .light : .dark
    }
}
