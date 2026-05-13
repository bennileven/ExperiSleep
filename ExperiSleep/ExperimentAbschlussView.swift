import SwiftUI

struct ExperimentAbschlussView: View {
    var experiment: AbgeschlossenesExperiment
    @EnvironmentObject private var speicher: CheckInSpeicher
    @EnvironmentObject private var aktiveExperimente: AktiveExperimente
    @Environment(\.dismiss) private var dismiss

    let cyan = Color(red: 0.0, green: 0.90, blue: 0.80)
    @State private var zeigeAuswertung = false

    var meta: (icon: String, farbe: Color) { iconUndFarbe(fuer: experiment.titel) }

    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.11, blue: 0.24)
                .ignoresSafeArea()

            VStack(spacing: 0) {

                // Header
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(meta.farbe.opacity(0.15))
                            .frame(width: 100, height: 100)
                        Image(systemName: meta.icon)
                            .font(.system(size: 44))
                            .foregroundColor(meta.farbe)
                    }
                    .padding(.top, 40)

                    Text("🏆 Experiment abgeschlossen!")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    Text(experiment.titel)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                }

                // Stats
                HStack(spacing: 12) {
                    AbschlussKarte(wert: "\(experiment.dauerInTagen)", label: "Tage", icon: "calendar", farbe: cyan)
                    AbschlussKarte(
                        wert: "\(speicher.eintraegeFor(experiment: experiment.titel).count)",
                        label: "Check-ins", icon: "checkmark.circle.fill", farbe: .green
                    )
                    AbschlussKarte(
                        wert: {
                            let eintraege = speicher.eintraegeFor(experiment: experiment.titel)
                            guard !eintraege.isEmpty else { return "—" }
                            let avg = Double(eintraege.reduce(0) { $0 + $1.schlafqualitaet }) / Double(eintraege.count)
                            return String(format: "%.1f", avg)
                        }(),
                        label: "Ø Schlaf", icon: "moon.fill", farbe: .indigo
                    )
                }
                .padding(.horizontal)
                .padding(.top, 32)

                Spacer()

                // Motivationstext
                Text("Du hast 14 Tage durchgehalten und echte Daten über deinen Schlaf gesammelt. Jetzt sieh dir an, was das Experiment bewirkt hat.")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                    .padding(.bottom, 30)

                // Buttons
                VStack(spacing: 12) {
                    Button(action: { zeigeAuswertung = true }) {
                        HStack {
                            Image(systemName: "chart.bar.fill")
                            Text("Auswertung ansehen")
                                .font(.headline)
                        }
                        .foregroundColor(Color(red: 0.05, green: 0.11, blue: 0.24))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(cyan)
                        .cornerRadius(14)
                    }

                    Button(action: { aktiveExperimente.neuAbgeschlossen = nil; dismiss() }) {
                        Text("Später ansehen")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
        }
        .sheet(isPresented: $zeigeAuswertung, onDismiss: {
            aktiveExperimente.neuAbgeschlossen = nil
            dismiss()
        }) {
            NavigationView {
                AuswertungView(experimentTitel: experiment.titel)
                    .environmentObject(speicher)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Fertig") {
                                zeigeAuswertung = false
                            }
                            .foregroundColor(cyan)
                        }
                    }
            }
        }
    }
}

struct AbschlussKarte: View {
    var wert: String
    var label: String
    var icon: String
    var farbe: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundColor(farbe)
                .font(.system(size: 18))
            Text(wert)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
            Text(label)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color.white.opacity(0.06))
        .cornerRadius(12)
    }
}
