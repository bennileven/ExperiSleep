//
//  KategorieDetailView.swift
//  ExperiSleep
//
//  Created by benni leven on 09.05.26.
//

import SwiftUI

struct KategorieDetailView: View {
    @EnvironmentObject var theme: AppTheme
    var kategorieName: String
    var kategorieIcon: String
    var kategorieFarbe: Color
    var experimente: [(titel: String, icon: String, farbe: Color)]
    
    var body: some View {
        ZStack {
            theme.hintergrund
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 12) {
                    
                    // Kategorie Header
                    HStack(spacing: 16) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(kategorieFarbe.opacity(0.2))
                                .frame(width: 60, height: 60)
                            Image(systemName: kategorieIcon)
                                .foregroundColor(kategorieFarbe)
                                .font(.system(size: 28))
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(kategorieName)
                                .font(.title2)
                                .bold()
                                .foregroundColor(.primary)
                            Text("\(experimente.count) Experimente verfügbar")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding()
                    .background(theme.karte)
                    .cornerRadius(14)
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // Experimente
                    ForEach(experimente, id: \.titel) { exp in
                        NavigationLink(destination: ExperimentDetailView(
                            titel: exp.titel,
                            icon: exp.icon,
                            color: exp.farbe
                        )) {
                            HStack(spacing: 14) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(exp.farbe.opacity(0.15))
                                        .frame(width: 44, height: 44)
                                    Image(systemName: exp.icon)
                                        .foregroundColor(exp.farbe)
                                        .font(.system(size: 18))
                                }
                                
                                Text(exp.titel)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                            }
                            .padding()
                            .background(theme.karte)
                            .cornerRadius(14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                        .frame(height: 30)
                }
            }
        }
        .navigationTitle(kategorieName)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

#Preview {
    NavigationView {
        KategorieDetailView(
            kategorieName: "Licht & Bildschirm",
            kategorieIcon: "display",
            kategorieFarbe: .blue,
            experimente: [
                (titel: "Kein Koffein nach 14 Uhr", icon: "cup.and.saucer.fill", farbe: .brown),
                (titel: "Handy weg ab 21 Uhr", icon: "iphone.slash", farbe: .blue),
            ]
        )
        .environmentObject(AktiveExperimente())
        .environmentObject(CheckInSpeicher())
    }
}
