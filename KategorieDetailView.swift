//
//  KategorieDetailView.swift
//  ExperiSleep
//
//  Created by benni leven on 09.05.26.
//

import SwiftUI

struct KategorieDetailView: View {
    var kategorieName: String
    var kategorieIcon: String
    var kategorieFarbe: Color
    var experimente: [(titel: String, icon: String, farbe: Color)]
    
    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.11, blue: 0.24)
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
                                .foregroundColor(.white)
                            Text("\(experimente.count) Experimente verfügbar")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.5))
                        }
                        Spacer()
                    }
                    .padding()
                    .background(Color.white.opacity(0.06))
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
                                    .foregroundColor(.white)
                                
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
