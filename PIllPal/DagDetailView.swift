import SwiftUI

extension Color {
    static let pillPalBackgroundDag = Color(red: 238/255, green: 228/255, blue: 245/255)
}

struct DagDetailView: View {
    let date: Date
    var onSave: (() -> Void)? = nil

    @State private var status: Double = -1
    @State private var bijwerkingen: String = ""

    let calendar = Calendar.current

    var body: some View {
        ZStack {
            Color.pillPalBackgroundDag
                .ignoresSafeArea()

            VStack(spacing: 20) {
                VStack(spacing: 30) {
                    Text("Status voor \(formattedDate(date))")
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .padding(.top)

                    Text(statusText())
                        .font(.headline)
                        .foregroundColor(statusColor())

                    HStack(spacing: 20) {
                        Button(action: {
                            saveStatus(1)
                        }) {
                            Text("✅ Genomen")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }

                        Button(action: {
                            saveStatus(0)
                        }) {
                            Text("❌ Niet genomen")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                    }

                    
                    VStack(alignment: .leading) {
                        Text("Bijwerkingen")
                            .font(.headline)

                        TextEditor(text: $bijwerkingen)
                            .frame(height: 100)
                            .padding(8)
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                            )

                        Button(action: {
                            saveBijwerkingen()
                        }) {
                            Text("Opslaan")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(20)
                .shadow(radius: 5)
                .padding(.horizontal)

                Spacer()
            }
            .padding()
        }
        .navigationTitle(formattedDate(date))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            let key = calendar.startOfDay(for: date).description
            let savedStatus = UserDefaults.standard.object(forKey: key) as? Double
            status = savedStatus ?? -1

            let bijwerkingenKey = bijwerkingenKeyForDate(date)
            bijwerkingen = UserDefaults.standard.string(forKey: bijwerkingenKey) ?? ""
        }
    }

    func saveStatus(_ newStatus: Double) {
        let key = calendar.startOfDay(for: date).description
        UserDefaults.standard.set(newStatus, forKey: key)
        status = newStatus
        onSave?()
    }

    func saveBijwerkingen() {
        let bijwerkingenKey = bijwerkingenKeyForDate(date)
        UserDefaults.standard.set(bijwerkingen, forKey: bijwerkingenKey)
        onSave?()
    }

    func bijwerkingenKeyForDate(_ date: Date) -> String {
        return "bijwerkingen_" + calendar.startOfDay(for: date).description
    }

    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "nl_BE")
        formatter.dateStyle = .full
        return formatter.string(from: date)
    }

    func statusText() -> String {
        switch status {
        case 1:
            return "✅ Pil genomen"
        case 0:
            return "❌ Pil niet genomen"
        default:
            return "⚠️ Nog niet ingesteld"
        }
    }

    func statusColor() -> Color {
        switch status {
        case 1:
            return .green
        case 0:
            return .red
        default:
            return .orange
        }
    }
}

#Preview {
    NavigationView {
        DagDetailView(date: Date())
    }
}
