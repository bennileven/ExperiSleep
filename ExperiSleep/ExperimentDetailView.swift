import SwiftUI

struct ExperimentDetailView: View {
    var titel: String
    var icon: String
    var color: Color
    
    var body: some View {
        VStack(spacing: 30) {
            
            // Icon und Titel
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 60))
                    .foregroundColor(color)
                
                Text(titel)
                    .font(.title2)
                    .bold()
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 40)
            
            // Erklärung
            VStack(alignment: .leading, spacing: 15) {
                InfoRow(icon: "1.circle.fill",
                        text: "Woche 1: Alles wie gewohnt — wir messen deinen normalen Schlaf")
                InfoRow(icon: "2.circle.fill",
                        text: "Woche 2: Du setzt das Experiment um und trackst die Veränderung")
                InfoRow(icon: "chart.bar.fill",
                        text: "Am Ende siehst du ob es wirklich geholfen hat")
            }
            .padding()
            .background(Color.gray.opacity(0.15))
            .cornerRadius(12)
            .padding(.horizontal)
            
            Spacer()
            
            // Start Button
            Button(action: {
                // hier kommt später der Check-in
            }) {
                Text("Experiment starten")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(color)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom, 30)
        }
        .navigationTitle("Experiment")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct InfoRow: View {
    var icon: String
    var text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.indigo)
            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    NavigationView {
        ExperimentDetailView(
            titel: "Kein Koffein nach 14 Uhr",
            icon: "cup.and.saucer.fill",
            color: .brown
        )
    }
}