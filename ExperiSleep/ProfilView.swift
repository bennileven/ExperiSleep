//
//  ProfilView.swift
//  ExperiSleep
//
//  Created by benni leven on 09.05.26.
//

import SwiftUI

struct ProfilView: View {
    @EnvironmentObject private var speicher: CheckInSpeicher
    @EnvironmentObject private var aktiveExperimente: AktiveExperimente
    @AppStorage("baselineSchlaf") var baselineSchlaf = 5.0
    @AppStorage("baselineEnergie") var baselineEnergie = 5.0
    @AppStorage("baselineStress") var baselineStress = 5.0
    @AppStorage("onboardingAbgeschlossen") var onboardingAbgeschlossen = true
    @AppStorage("nutzername") var nutzername = "Mein Profil"
    @AppStorage("mitteilungenAktiv") var mitteilungenAktiv = true
    @State private var zeigeNameBearbeiten = false
    @State private var neuerName = ""
    
    let cyan = Color(red: 0.0, green: 0.90, blue: 0.80)
    
    var gesamtCheckIns: Int { speicher.eintraege.count }
    
    var gesamtExperimente: Int { aktiveExperimente.aktive.count }
    
    var durchschnittSchlaf: Double {
        guard !speicher.eintraege.isEmpty else { return 0 }
        return Double(speicher.eintraege.reduce(0) { $0 + $1.schlafqualitaet }) / Double(speicher.eintraege.count)
    }
    
    var verbesserung: Double {
        guard durchschnittSchlaf > 0 else { return 0 }
        return durchschnittSchlaf - baselineSchlaf
    }
    
    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.11, blue: 0.24)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    
                    // ── Profil Header ──
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(cyan.opacity(0.2))
                                .frame(width: 80, height: 80)
                            Image("logo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                                .cornerRadius(30)
                        }
                        
                        Button(action: {
                            neuerName = nutzername
                            zeigeNameBearbeiten = true
                        }) {
                            HStack(spacing: 6) {
                                Text(nutzername)
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(.white)
                                Image(systemName: "pencil")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.4))
                            }
                        }
                        
                        Text("ExperiSleep Nutzer")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .padding(.top, 20)
                    
                    // ── Statistiken ──
                    VStack(spacing: 12) {
                        Text("Meine Statistiken")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.7))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        
                        HStack(spacing: 12) {
                            ProfilKarte(
                                titel: "Check-ins",
                                wert: "\(gesamtCheckIns)",
                                icon: "checkmark.circle.fill",
                                farbe: cyan
                            )
                            ProfilKarte(
                                titel: "Experimente",
                                wert: "\(gesamtExperimente)",
                                icon: "flask.fill",
                                farbe: .indigo
                            )
                            ProfilKarte(
                                titel: "Verbesserung",
                                wert: verbesserung > 0 ? "+\(String(format: "%.1f", verbesserung))" : String(format: "%.1f", verbesserung),
                                icon: verbesserung >= 0 ? "arrow.up.circle.fill" : "arrow.down.circle.fill",
                                farbe: verbesserung >= 0 ? .green : .red
                            )
                        }
                        .padding(.horizontal)
                    }
                    //SchlafInfo//
                    
                    NavigationLink(destination: VerlaufView()
                        .environmentObject(speicher)
                        .environmentObject(aktiveExperimente)
                    ) {
                        HStack {
                            Image(systemName: "clock.arrow.circlepath")
                                .foregroundColor(.indigo)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Vergangene Experimente")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                Text("\(aktiveExperimente.vergangene.count) abgeschlossen")
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.45))
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.white.opacity(0.3))
                                .font(.caption)
                        }
                        .padding()
                        .background(Color.white.opacity(0.06))
                        .cornerRadius(14)
                    }
                    .padding(.horizontal)

                    NavigationLink(destination: SchlafInfoView()) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(cyan)
                            Text("Schlaf & Daten Info")
                                .font(.subheadline)
                                .foregroundColor(.white)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.white.opacity(0.3))
                                .font(.caption)
                        }
                        .padding()
                        .background(Color.white.opacity(0.06))
                        .cornerRadius(14)
                    }
                    .padding(.horizontal)
                    
                    // ── Ausgangswerte ──
                    VStack(spacing: 16) {
                        Text("Meine Ausgangswerte")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.7))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        ProfilSlider(
                            titel: "Schlafqualität",
                            icon: "moon.fill",
                            farbe: .indigo,
                            wert: $baselineSchlaf
                        )
                        
                        Divider().background(Color.white.opacity(0.1))
                        
                        ProfilSlider(
                            titel: "Energie morgens",
                            icon: "bolt.fill",
                            farbe: .orange,
                            wert: $baselineEnergie
                        )
                        
                        Divider().background(Color.white.opacity(0.1))
                        
                        ProfilSlider(
                            titel: "Stresslevel",
                            icon: "brain.head.profile",
                            farbe: .red,
                            wert: $baselineStress
                        )
                    }
                    .padding()
                    .background(Color.white.opacity(0.06))
                    .cornerRadius(14)
                    .padding(.horizontal)
                    
                    // ── Aktive Experimente ──
                    if !aktiveExperimente.aktive.isEmpty {
                        VStack(spacing: 12) {
                            Text("Aktive Experimente")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.7))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                            
                            ForEach(aktiveExperimente.aktiveNamen, id: \.self) { titel in
                                HStack {
                                    Circle()
                                        .fill(Color.green)
                                        .frame(width: 8, height: 8)
                                    Text(titel)
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                    Spacer()
                                    if let start = aktiveExperimente.startDatum(fuer: titel) {
                                        let tage = Calendar.current.dateComponents([.day], from: start, to: Date()).day ?? 0
                                        Text("Tag \(tage + 1)/14")
                                            .font(.caption)
                                            .foregroundColor(.green.opacity(0.8))
                                    }
                                }
                                .padding()
                                .background(Color.green.opacity(0.08))
                                .cornerRadius(12)
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    // ── Einstellungen ──
                    VStack(spacing: 12) {
                        Toggle(isOn: $mitteilungenAktiv) {
                            HStack(spacing: 12) {
                                Image(systemName: "bell.fill")
                                    .foregroundColor(cyan)
                                    .frame(width: 20)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Erinnerungen")
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                    Text("12:00 Uhr & 21:00 Uhr (falls kein Check-in)")
                                        .font(.caption2)
                                        .foregroundColor(.white.opacity(0.45))
                                }
                            }
                        }
                        .tint(cyan)
                        .padding()
                        .background(Color.white.opacity(0.06))
                        .cornerRadius(14)
                        .onChange(of: mitteilungenAktiv) { aktiv in
                            if aktiv {
                                NotificationManager.shared.berechtigungAnfragen()
                                NotificationManager.shared.erinnerungenPlanen()
                            } else {
                                NotificationManager.shared.alleDeaktivieren()
                            }
                        }
                    }
                    .padding(.horizontal)

                    // ── Daten zurücksetzen ──
                    VStack(spacing: 12) {
                        Button(action: {
                            onboardingAbgeschlossen = false
                        }) {
                            HStack {
                                Image(systemName: "arrow.counterclockwise")
                                    .foregroundColor(.orange)
                                Text("Onboarding wiederholen")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.white.opacity(0.3))
                                    .font(.caption)
                            }
                            .padding()
                            .background(Color.white.opacity(0.06))
                            .cornerRadius(14)
                        }
                        .padding(.horizontal)
                        
                        Button(action: {
                            speicher.loeschen { _ in true }
                        }) {
                            HStack {
                                Image(systemName: "trash.fill")
                                    .foregroundColor(.red)
                                Text("Alle Check-ins löschen")
                                    .font(.subheadline)
                                    .foregroundColor(.red)
                                Spacer()
                            }
                            .padding()
                            .background(Color.red.opacity(0.08))
                            .cornerRadius(14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.red.opacity(0.2), lineWidth: 1)
                            )
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                        .frame(height: 40)
                }
            }
        }
        .navigationTitle("Profil")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .alert("Name ändern", isPresented: $zeigeNameBearbeiten) {
            TextField("Dein Name", text: $neuerName)
            Button("Speichern") { nutzername = neuerName }
            Button("Abbrechen", role: .cancel) {}
        }
    }
}

struct ProfilKarte: View {
    var titel: String
    var wert: String
    var icon: String
    var farbe: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(farbe)
                .font(.system(size: 20))
            Text(wert)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            Text(titel)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.5))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.06))
        .cornerRadius(12)
    }
}

struct ProfilSlider: View {
    var titel: String
    var icon: String
    var farbe: Color
    @Binding var wert: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(farbe)
                Text(titel)
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(.white)
                Spacer()
                Text("\(Int(wert)) / 10")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.6))
            }
            Slider(value: $wert, in: 1...10, step: 1)
                .tint(farbe)
        }
    }
}

#Preview {
    NavigationView {
        ProfilView()
            .environmentObject(CheckInSpeicher())
            .environmentObject(AktiveExperimente())
    }
}
