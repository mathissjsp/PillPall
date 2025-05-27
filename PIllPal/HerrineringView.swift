import SwiftUI
import UserNotifications

extension Color {
    static let pillPalBackgroundHerrinering = Color(red: 238/255, green: 228/255, blue: 245/255)
}

struct HerrineringView: View {
    @State private var selectedTime = Date()
    @State private var permissionGranted = false
    @State private var showConfirmationAlert = false
    @State private var showRemoveAlert = false            // <-- nieuwe state variabele
    @State private var scheduledTimes: [Date] = []

    var body: some View {
        ZStack {
            Color.pillPalBackgroundHerrinering
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Herinnering instellen")
                    .font(.title)
                    .foregroundColor(.purple)
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 20)
                    .padding(.horizontal, 30)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gray.opacity(0.4), lineWidth: 2)
                    )
                    .cornerRadius(20)
                
                Text("stel hier in hoelaat je elke dag een herinnering wil krijgen om de pil te nemen")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.top)
                
                

                DatePicker("Kies tijdstip", selection: $selectedTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()

                Button("Plan Herinnering") {
                    schedulePillReminder(at: selectedTime)
                }
                .padding()
                .background(permissionGranted ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(!permissionGranted)

                if !scheduledTimes.isEmpty {
                    VStack(alignment: .leading) {
                        Text("Geplande herinneringen:")
                            .font(.headline)
                        ForEach(scheduledTimes, id: \.self) { time in
                            HStack {
                                Text(timeString(from: time))
                                Spacer()
                                Button {
                                    removeReminder(at: time)
                                } label: {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            }
                            .padding(.vertical, 2)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                }

                Spacer()
            }
            .padding()
        }
        .onAppear {
            requestNotificationPermission()
            loadScheduledTimes()
        }
        .alert("Herinnering gepland", isPresented: $showConfirmationAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Je zal elke dag een melding krijgen om je pil te nemen.")
        }
        .alert("Herinnering verwijderd", isPresented: $showRemoveAlert) {    // <-- nieuwe alert
            Button("OK", role: .cancel) { }
        } message: {
            Text("De herinnering is succesvol verwijderd.")
        }
    }

    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                permissionGranted = granted
                if granted {
                    print("Toestemming gegeven voor notificaties")
                } else {
                    print("Geen toestemming voor notificaties")
                }
            }
        }
    }

    func schedulePillReminder(at time: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Pilletje tijd 💊"
        content.body = "Vergeet je pil niet te nemen!"
        content.sound = UNNotificationSound.default

        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: time)
        let minute = calendar.component(.minute, from: time)

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Fout bij plannen notificatie: \(error.localizedDescription)")
                } else {
                    print("Herinnering gepland om \(hour):\(minute)")
                    if !scheduledTimes.contains(where: { Calendar.current.isDate($0, equalTo: time, toGranularity: .minute) }) {
                        scheduledTimes.append(time)
                        saveScheduledTimes()
                    }
                    showConfirmationAlert = true
                }
            }
        }
    }

    func removeReminder(at time: Date) {
        scheduledTimes.removeAll { Calendar.current.isDate($0, equalTo: time, toGranularity: .minute) }
        saveScheduledTimes()

        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let identifiersToRemove = requests.filter {
                guard let trigger = $0.trigger as? UNCalendarNotificationTrigger,
                      let triggerDate = trigger.nextTriggerDate() else { return false }
                return Calendar.current.isDate(triggerDate, equalTo: time, toGranularity: .minute)
            }.map { $0.identifier }

            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiersToRemove)
            
            DispatchQueue.main.async {
                showRemoveAlert = true   // <-- hier alert tonen na verwijderen
            }
        }
    }

    func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    func saveScheduledTimes() {
        let data = scheduledTimes.map { $0.timeIntervalSince1970 }
        UserDefaults.standard.set(data, forKey: "scheduledTimes")
    }

    func loadScheduledTimes() {
        if let savedData = UserDefaults.standard.array(forKey: "scheduledTimes") as? [TimeInterval] {
            scheduledTimes = savedData.map { Date(timeIntervalSince1970: $0) }
        }
    }
}

#Preview {
    HerrineringView()
}
