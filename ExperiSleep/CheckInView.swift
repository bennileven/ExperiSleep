import SwiftUI
import HealthKit

struct CheckInView: View {
    var experimentTitel: String
    var istBaseline: Bool = true
    
    @EnvironmentObject private var speicher: CheckInSpeicher
    @State private var schlafqualitaet: Double = 5
    @State private var energie: Double = 5
    @State private var stress: Double = 5
    @State private var schlafStunden: Double = 0
    @State private var gespeichert = false
    @State private var laedt = true
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.11, blue: 0.24)
                .ignoresSafeArea()
            
            VStack(spacing: 25) {
                
                Text("Morgen Check-in")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)
                    .padding(.top, 20)
                
                Text(istBaseline ? "Woche 1 — Baseline" : "Woche 2 — Experiment")
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(istBaseline ? Color.white.opacity(0.1) : Color.indigo.opacity(0.3))
                    .foregroundColor(.white)
                    .cornerRadius(20)
                
                Text(experimentTitel)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.6))
                
                if schlafStunden > 0 {
                    HStack(spacing: 8) {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                            .font(.caption)
                        Text("\(String(format: "%.1f", schlafStunden))h Schlaf aus Apple Health")
                            .font(.caption)
                            .foregroundColor(.green)
                        Spacer()
                    }
                    .padding(.horizontal)
                } else if laedt {
                    HStack {
                        ProgressView()
                            .tint(.white)
                        Text("Schlafdaten werden geladen...")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }
                } else {
                    HStack {
                        Image(systemName: "exclamationmark.circle")
                            .foregroundColor(.orange)
                            .font(.caption)
                        Text("Keine Schlafdaten — bitte manuell eingeben")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                        Spacer()
                    }
                    .padding(.horizontal)
                }
                
                VStack(spacing: 20) {
                    SliderRow(
                        titel: "Schlafqualität",
                        icon: "moon.fill",
                        color: .indigo,
                        wert: $schlafqualitaet
                    )
                    
                    Divider()
                        .background(Color.white.opacity(0.2))
                    
                    SliderRow(
                        titel: "Energie heute",
                        icon: "bolt.fill",
                        color: .orange,
                        wert: $energie
                    )
                    
                    Divider()
                        .background(Color.white.opacity(0.2))
                    
                    SliderRow(
                        titel: "Stresslevel",
                        icon: "brain.head.profile",
                        color: .red,
                        wert: $stress
                    )
                }
                .padding()
                .background(Color.white.opacity(0.06))
                .cornerRadius(14)
                .padding(.horizontal)
                
                Spacer()
                
                Button(action: {
                    let eintrag = CheckInEintrag(
                        datum: Date(),
                        schlafqualitaet: Int(schlafqualitaet),
                        energie: Int(energie),
                        stress: Int(stress),
                        experimentTitel: experimentTitel,
                        istBaseline: istBaseline
                    )
                    speicher.speichern(eintrag: eintrag)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        FirebaseManager.shared.checkInSpeichern(eintrag: eintrag)
                    }
                    gespeichert = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        dismiss()
                    }
                }) {
                    Text(gespeichert ? "Gespeichert ✓" : "Check-in speichern")
                        .font(.headline)
                        .foregroundColor(gespeichert ? .white : Color(red: 0.05, green: 0.11, blue: 0.24))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(gespeichert ? Color.green : Color(red: 0.0, green: 0.90, blue: 0.80))
                        .cornerRadius(14)
                }
                .disabled(gespeichert)
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
        }
        .navigationTitle("Check-in")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .onAppear {
            ladeHealthDaten()
        }
    }
    
    func ladeHealthDaten() {
        HealthKitManager.shared.berechtigungAnfragen { erfolg in
            if erfolg {
                HealthKitManager.shared.schlafdatenLaden { stunden, qualitaet in
                    schlafStunden = stunden
                    if stunden > 0 {
                        schlafqualitaet = Double(qualitaet)
                    }
                    laedt = false
                }
            } else {
                laedt = false
            }
        }
    }
}

struct SliderRow: View {
    var titel: String
    var icon: String
    var color: Color
    @Binding var wert: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
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
                .tint(color)
        }
    }
}

#Preview {
    NavigationView {
        CheckInView(experimentTitel: "Kein Koffein nach 14 Uhr")
            .environmentObject(CheckInSpeicher())
    }
}
