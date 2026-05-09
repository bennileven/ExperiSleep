//
//  ExperimenteListeView.swift
//  ExperiSleep
//
//  Created by benni leven on 09.05.26.
//
import SwiftUI

struct ExperimenteListeView: View {
    @EnvironmentObject private var aktiveExperimente: AktiveExperimente
    @State private var zeigeErstellen = false
    @State private var eigeneExperimente: [EigenesExperiment] = []
    
    let cyan = Color(red: 0.0, green: 0.90, blue: 0.80)
    
    let kategorien: [(name: String, icon: String, farbe: Color, experimente: [(titel: String, icon: String, farbe: Color)])] = [
        (
            name: "Licht & Bildschirm",
            icon: "display",
            farbe: .blue,
            experimente: [
                (titel: "Kein Koffein nach 14 Uhr", icon: "cup.and.saucer.fill", farbe: .brown),
                (titel: "Handy weg ab 21 Uhr", icon: "iphone.slash", farbe: .blue),
                (titel: "Blaues Licht Filter ab 20 Uhr", icon: "eyeglasses", farbe: .indigo),
            ]
        ),
        (
            name: "Entspannung & Stress",
            icon: "brain.head.profile",
            farbe: .purple,
            experimente: [
                (titel: "10 Min Meditation vor Bett", icon: "brain.head.profile", farbe: .purple),
                (titel: "5 Min Tagebuch schreiben", icon: "square.and.pencil", farbe: .orange),
                (titel: "Atemübung vor dem Schlafen", icon: "wind", farbe: .teal),
            ]
        ),
        (
            name: "Ernährung & Körper",
            icon: "fork.knife.circle.fill",
            farbe: .green,
            experimente: [
                (titel: "Kein Essen nach 18 Uhr", icon: "fork.knife.circle.fill", farbe: .green),
                (titel: "Kein Alkohol unter der Woche", icon: "wineglass.fill", farbe: .red),
                (titel: "Jeden Tag 8 Gläser Wasser", icon: "drop.fill", farbe: .cyan),
            ]
        ),
        (
            name: "Bewegung & Umgebung",
            icon: "figure.walk",
            farbe: .mint,
            experimente: [
                (titel: "30 Min Spaziergang täglich", icon: "figure.walk", farbe: .mint),
                (titel: "Zimmer auf 18 Grad kühlen", icon: "thermometer.snowflake", farbe: .blue),
                (titel: "Kein Sport nach 20 Uhr", icon: "figure.run", farbe: .orange),
            ]
        ),
        (
            name: "Routine",
            icon: "clock.fill",
            farbe: .indigo,
            experimente: [
                (titel: "Jeden Tag gleiche Schlafzeit", icon: "clock.fill", farbe: .indigo),
                (titel: "10 Min Lesen statt Handy", icon: "book.fill", farbe: .brown),
                (titel: "Magnesium vor dem Schlafen", icon: "pills.fill", farbe: .purple),
            ]
        )
    ]
    
    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.11, blue: 0.24)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 16) {
                    
                    // Kategorien
                    ForEach(kategorien, id: \.name) { kategorie in
                        NavigationLink(destination: KategorieDetailView(
                            kategorieName: kategorie.name,
                            kategorieIcon: kategorie.icon,
                            kategorieFarbe: kategorie.farbe,
                            experimente: kategorie.experimente
                        )) {
                            HStack(spacing: 16) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(kategorie.farbe.opacity(0.2))
                                        .frame(width: 44, height: 44)
                                    Image(systemName: kategorie.icon)
                                        .foregroundColor(kategorie.farbe)
                                        .font(.system(size: 20))
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(kategorie.name)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Text("\(kategorie.experimente.count) Experimente")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.5))
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.white.opacity(0.3))
                                    .font(.caption)
                            }
                            .padding()
                            .background(Color.white.opacity(0.06))
                            .cornerRadius(14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal)
                    }
                    
                    // Eigenes Experiment
                    Button(action: { zeigeErstellen = true }) {
                        HStack(spacing: 16) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(cyan.opacity(0.2))
                                    .frame(width: 44, height: 44)
                                Image(systemName: "plus")
                                    .foregroundColor(cyan)
                                    .font(.system(size: 20))
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Eigenes Experiment")
                                    .font(.headline)
                                    .foregroundColor(cyan)
                                Text("Erstelle dein eigenes Experiment")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.5))
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.white.opacity(0.3))
                                .font(.caption)
                        }
                        .padding()
                        .background(cyan.opacity(0.08))
                        .cornerRadius(14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(cyan.opacity(0.2), lineWidth: 1)
                        )
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
                .padding(.top, 16)
            }
        }
        .navigationTitle("Experiment starten")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
        .sheet(isPresented: $zeigeErstellen) {
            ExperimentErstellenView(experimente: $eigeneExperimente)
        }
    }
}

#Preview {
    NavigationView {
        ExperimenteListeView()
            .environmentObject(AktiveExperimente())
    }
}

