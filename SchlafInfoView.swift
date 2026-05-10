//
//  SchlafInfoView.swift
//  ExperiSleep
//
//  Created by benni leven on 09.05.26.
//

import SwiftUI

struct SchlafInfoView: View {
    let cyan = Color(red: 0.0, green: 0.90, blue: 0.80)
    
    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.11, blue: 0.24)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "moon.stars.fill")
                            .font(.system(size: 50))
                            .foregroundColor(cyan)
                        Text("Wie wird mein Schlaf analysiert?")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        Text("Alle Infos zur Datenerfassung und Auswertung")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.6))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    .padding(.horizontal)
                    
                    // Wie wird der Schlafwert berechnet
                    InfoKarte(
                        icon: "function",
                        farbe: cyan,
                        titel: "Wie wird dein Schlafwert berechnet?",
                        inhalt: """
                        ExperiSleep liest deine Schlafdaten direkt aus Apple Health. Dabei werden nur die echten Schlafphasen gezählt — also Tiefschlaf, REM-Schlaf und Kernschlaf. Wachphasen oder Ruhephasen werden nicht berücksichtigt.

                        Aus der gesamten Schlafdauer wird dann ein Qualitätswert von 1–10 berechnet:
                        """
                    )
                    
                    // Bewertungstabelle
                    VStack(spacing: 0) {
                        Text("Schlafdauer → Qualitätswert")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.5))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            .padding(.bottom, 8)
                        
                        VStack(spacing: 2) {
                            BewertungsZeile(stunden: "< 4 Stunden", wert: "2 / 10", farbe: .red)
                            BewertungsZeile(stunden: "4 – 5 Stunden", wert: "4 / 10", farbe: .orange)
                            BewertungsZeile(stunden: "5 – 6 Stunden", wert: "5 / 10", farbe: .orange)
                            BewertungsZeile(stunden: "6 – 7 Stunden", wert: "6 / 10", farbe: .yellow)
                            BewertungsZeile(stunden: "7 – 8 Stunden", wert: "8 / 10", farbe: cyan)
                            BewertungsZeile(stunden: "> 8 Stunden", wert: "9 / 10", farbe: .green)
                        }
                        .padding(.horizontal)
                    }
                    
                    // Schlafphasen
                    InfoKarte(
                        icon: "waveform.path.ecg",
                        farbe: .indigo,
                        titel: "Welche Schlafphasen werden erfasst?",
                        inhalt: """
                        Apple Health unterscheidet zwischen vier Schlafphasen:

                        • Tiefschlaf (Deep Sleep): Körperliche Erholung, Immunsystem, Muskelaufbau
                        • REM-Schlaf: Mentale Erholung, Gedächtniskonsolidierung, Träume
                        • Kernschlaf (Core Sleep): Leichter Schlaf zwischen den Tiefphasen
                        • Wach: Kurze Wachphasen die normal sind

                        ExperiSleep zählt Tief-, REM- und Kernschlaf als echten Schlaf. Nur diese Phasen fließen in deinen Qualitätswert ein.
                        """
                    )
                    
                    // Wie wird getrackt
                    InfoKarte(
                        icon: "applewatch",
                        farbe: .gray,
                        titel: "Wie wird der Schlaf getrackt?",
                        inhalt: """
                        Die besten Ergebnisse bekommst du mit einer Apple Watch — sie erkennt Schlafphasen automatisch über Herzfrequenz und Bewegungssensoren.

                        Ohne Apple Watch kann das iPhone den Schlaf über Bewegungserkennung tracken. Aktiviere dazu in der Gesundheits-App unter Einstellungen → Schlaf die automatische Schlaferfassung.

                        Wichtig: Das iPhone muss während des Schlafs aufgeladen werden und in der Nähe liegen.
                        """
                    )
                    
                    // Ausgangswert
                    InfoKarte(
                        icon: "scope",
                        farbe: .orange,
                        titel: "Was ist der Ausgangswert?",
                        inhalt: """
                        Der Ausgangswert ist deine persönliche Schlaf-Baseline — also wie gut du vor dem Experiment geschlafen hast.

                        Du hast diesen Wert beim ersten Start der App selbst eingeschätzt. Er dient als Vergleichspunkt für alle Experimente.

                        Du kannst deinen Ausgangswert jederzeit im Profil anpassen, falls er nicht mehr aktuell ist.
                        """
                    )
                    
                    // Datenschutz
                    InfoKarte(
                        icon: "lock.shield.fill",
                        farbe: .green,
                        titel: "Datenschutz & Sicherheit",
                        inhalt: """
                        ExperiSleep liest deine Gesundheitsdaten nur mit deiner ausdrücklichen Erlaubnis. Die Daten verlassen dein Gerät nur wenn du sie in der Cloud speicherst.

                        In der Rangliste werden ausschließlich anonyme IDs verwendet — dein Name oder persönliche Daten werden nie öffentlich geteilt.

                        Du kannst den Zugriff auf Apple Health jederzeit in den iPhone-Einstellungen unter Gesundheit → Datenzugriff widerrufen.
                        """
                    )
                    
                    // Wissenschaftlicher Hintergrund
                    InfoKarte(
                        icon: "books.vertical.fill",
                        farbe: .purple,
                        titel: "Wissenschaftlicher Hintergrund",
                        inhalt: """
                        ExperiSleep basiert auf dem Prinzip des N=1 Selbstexperiments — du bist dein eigener Wissenschaftler. Statt Durchschnittswerte zu nutzen, findest du heraus was für dich persönlich funktioniert.

                        Studien zeigen dass Schlaf, Ernährung, Bewegung und Stress eng miteinander verbunden sind. Kleine Verhaltensänderungen können messbare Auswirkungen auf die Schlafqualität haben.

                        Empfohlene Lektüre: "Outlive" von Dr. Peter Attia — das Standardwerk zur Longevity und Schlafforschung.
                        """
                    )
                    
                    Spacer()
                        .frame(height: 40)
                }
            }
        }
        .navigationTitle("Schlaf & Daten Info")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

struct InfoKarte: View {
    var icon: String
    var farbe: Color
    var titel: String
    var inhalt: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .foregroundColor(farbe)
                    .font(.system(size: 18))
                Text(titel)
                    .font(.headline)
                    .foregroundColor(.white)
            }
            Text(inhalt)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
                .lineSpacing(4)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.06))
        .cornerRadius(14)
        .padding(.horizontal)
    }
}

struct BewertungsZeile: View {
    var stunden: String
    var wert: String
    var farbe: Color
    
    var body: some View {
        HStack {
            Text(stunden)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
            Spacer()
            Text(wert)
                .font(.subheadline)
                .bold()
                .foregroundColor(farbe)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.04))
        .cornerRadius(8)
    }
}

#Preview {
    NavigationView {
        SchlafInfoView()
    }
}
