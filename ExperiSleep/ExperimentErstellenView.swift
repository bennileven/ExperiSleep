import SwiftUI

struct ExperimentErstellenView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var experimente: [EigenesExperiment]
    
    @State private var titel = ""
    @State private var beschreibung = ""
    @State private var gewaehltesFarbname = "indigo"
    @State private var gewaehltesIcon = "moon.stars.fill"
    
    let farben = ["indigo", "blue", "green", "orange", "pink", "purple", "red"]
    let icons = [
        "moon.stars.fill", "cup.and.saucer.fill", "iphone.slash",
        "brain.head.profile", "figure.walk", "heart.fill",
        "leaf.fill", "bolt.fill", "sun.max.fill", "bed.double.fill"
    ]
    
    var farbeAlsColor: Color {
        farbeVon(name: gewaehltesFarbname)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Eigene Titelleiste
            HStack {
                Button("Abbrechen") { dismiss() }
                    .foregroundColor(.red)
                Spacer()
                Text("Neues Experiment")
                    .font(.headline)
                Spacer()
                Button("Speichern") {
                    guard !titel.isEmpty else { return }
                    let neues = EigenesExperiment(
                        titel: titel,
                        beschreibung: beschreibung,
                        icon: gewaehltesIcon,
                        farbname: gewaehltesFarbname
                    )
                    experimente.append(neues)
                    dismiss()
                }
                .foregroundColor(titel.isEmpty ? .gray : .indigo)
                .disabled(titel.isEmpty)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Vorschau
                    VStack(spacing: 10) {
                        Image(systemName: gewaehltesIcon)
                            .font(.system(size: 50))
                            .foregroundColor(farbeAlsColor)
                        Text(titel.isEmpty ? "Mein Experiment" : titel)
                            .font(.headline)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Titel
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Titel")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        TextField("z.B. Kein Zucker nach 18 Uhr", text: $titel)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                            .padding(.horizontal)
                    }
                    
                    // Beschreibung
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Beschreibung")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        TextField("Was möchtest du testen?", text: $beschreibung, axis: .vertical)
                            .lineLimit(3...5)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                            .padding(.horizontal)
                    }
                    
                    // Icon wählen
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Icon wählen")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                            ForEach(icons, id: \.self) { icon in
                                Button(action: { gewaehltesIcon = icon }) {
                                    Image(systemName: icon)
                                        .font(.system(size: 24))
                                        .foregroundColor(gewaehltesIcon == icon ? farbeAlsColor : .gray)
                                        .frame(width: 44, height: 44)
                                        .background(gewaehltesIcon == icon ? farbeAlsColor.opacity(0.15) : Color.clear)
                                        .cornerRadius(8)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Farbe wählen
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Farbe wählen")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        HStack(spacing: 12) {
                            ForEach(farben, id: \.self) { farbname in
                                Button(action: { gewaehltesFarbname = farbname }) {
                                    Circle()
                                        .fill(farbeVon(name: farbname))
                                        .frame(width: 36, height: 36)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.primary, lineWidth: gewaehltesFarbname == farbname ? 3 : 0)
                                                .padding(2)
                                        )
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                }
                .padding(.vertical)
            }
        }
    }
    
    func farbeVon(name: String) -> Color {
        switch name {
        case "blue": return .blue
        case "green": return .green
        case "orange": return .orange
        case "pink": return .pink
        case "purple": return .purple
        case "red": return .red
        default: return .indigo
        }
    }
}
