import SwiftUI

struct AnmeldenView: View {
    @EnvironmentObject var theme: AppTheme
    @AppStorage("onboardingAbgeschlossen") var onboardingAbgeschlossen = false

    enum Modus { case anmelden, registrieren }
    @State private var modus: Modus = .registrieren

    @State private var email = ""
    @State private var passwort = ""
    @State private var passwortWiederholen = ""
    @State private var laedt = false
    @State private var fehler: String? = nil
    @FocusState private var fokus: Feld?

    enum Feld { case email, passwort, passwortWiederholen }

    let cyan = Color(red: 0.0, green: 0.90, blue: 0.80)

    var buttonDeaktiviert: Bool {
        email.isEmpty || passwort.isEmpty ||
        (modus == .registrieren && passwort != passwortWiederholen)
    }

    var body: some View {
        ZStack {
            theme.hintergrund.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 32) {

                    // Logo
                    VStack(spacing: 12) {
                        Image("logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .cornerRadius(20)

                        Text("ExperiSleep")
                            .font(.title)
                            .bold()
                            .foregroundColor(.primary)
                    }
                    .padding(.top, 60)

                    // Modus-Toggle
                    HStack(spacing: 0) {
                        ForEach([Modus.registrieren, Modus.anmelden], id: \.self) { m in
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    modus = m
                                    fehler = nil
                                }
                            }) {
                                Text(m == .registrieren ? "Registrieren" : "Einloggen")
                                    .font(.subheadline)
                                    .fontWeight(modus == m ? .bold : .regular)
                                    .foregroundColor(modus == m ? theme.hintergrund : .secondary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(modus == m ? cyan : Color.clear)
                            }
                        }
                    }
                    .background(Color.primary.opacity(0.08))
                    .cornerRadius(12)
                    .padding(.horizontal)

                    // Felder
                    VStack(spacing: 14) {
                        TextField("E-Mail-Adresse", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .focused($fokus, equals: .email)
                            .submitLabel(.next)
                            .onSubmit { fokus = .passwort }
                            .padding()
                            .background(Color.primary.opacity(0.06))
                            .cornerRadius(12)

                        SecureField("Passwort", text: $passwort)
                            .focused($fokus, equals: .passwort)
                            .submitLabel(modus == .registrieren ? .next : .done)
                            .onSubmit {
                                if modus == .registrieren { fokus = .passwortWiederholen }
                                else { aktion() }
                            }
                            .padding()
                            .background(Color.primary.opacity(0.06))
                            .cornerRadius(12)

                        if modus == .registrieren {
                            SecureField("Passwort wiederholen", text: $passwortWiederholen)
                                .focused($fokus, equals: .passwortWiederholen)
                                .submitLabel(.done)
                                .onSubmit { aktion() }
                                .padding()
                                .background(Color.primary.opacity(0.06))
                                .cornerRadius(12)

                            if !passwort.isEmpty && !passwortWiederholen.isEmpty && passwort != passwortWiederholen {
                                Text("Passwörter stimmen nicht überein.")
                                    .font(.caption)
                                    .foregroundColor(.red)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }

                        if let fehler = fehler {
                            Text(fehler)
                                .font(.caption)
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(.horizontal)

                    // Haupt-Button
                    Button(action: aktion) {
                        Group {
                            if laedt {
                                ProgressView().tint(theme.hintergrund)
                            } else {
                                Text(modus == .registrieren ? "Konto erstellen" : "Einloggen")
                                    .font(.headline)
                                    .foregroundColor(theme.hintergrund)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(buttonDeaktiviert ? Color.primary.opacity(0.2) : cyan)
                        .cornerRadius(14)
                    }
                    .disabled(buttonDeaktiviert || laedt)
                    .padding(.horizontal)

                    Text("Mit deinem Konto kannst du dich auf mehreren Geräten einloggen und deine Daten behalten.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    Spacer(minLength: 40)
                }
            }
        }
    }

    private func aktion() {
        fokus = nil
        fehler = nil
        laedt = true

        if modus == .registrieren {
            FirebaseManager.shared.registrieren(email: email, passwort: passwort) { fehlerText in
                laedt = false
                if let f = fehlerText {
                    fehler = f
                } else {
                    // Nach Registrierung → Onboarding durchlaufen
                    onboardingAbgeschlossen = false
                }
            }
        } else {
            FirebaseManager.shared.einloggen(email: email, passwort: passwort) { fehlerText in
                laedt = false
                if let f = fehlerText {
                    fehler = f
                } else {
                    // Bei Login auf neuem Gerät → Onboarding überspringen
                    onboardingAbgeschlossen = true
                }
            }
        }
    }
}

extension AnmeldenView.Modus: Hashable {}
