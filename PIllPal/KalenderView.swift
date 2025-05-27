import SwiftUI

extension Color {
    static let pillPalBackgroundKalender = Color(red: 238/255, green: 228/255, blue: 245/255)
}

struct KalenderView: View {
    @State private var refreshID = UUID()
    @State private var currentMonth = Date()

    let calendar = Calendar.current
    let today = Date()

    var body: some View {
        NavigationView {
            ZStack {
                Color.pillPalBackgroundKalender
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    VStack{
                        Text("Jouw kalender")
                            .font(.title)
                            .bold()

                        Text("Houd hier bij welke dagen je de pil hebt gepakt")
                            .font(.caption)
                            .foregroundColor(.gray)

                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(radius: 5)


                    VStack(spacing: 16) {
                        HStack {
                            Button(action: {
                                changeMonth(by: -1)
                            }) {
                                Image(systemName: "chevron.left")
                            }

                            Spacer()

                            Text(monthYearString(from: currentMonth))
                                .font(.title2)
                                .bold()

                            Spacer()

                            Button(action: {
                                changeMonth(by: 1)
                            }) {
                                Image(systemName: "chevron.right")
                            }
                        }
                        .padding(.horizontal)

                        let weekdays = calendar.shortStandaloneWeekdaySymbols
                        HStack {
                            ForEach(0..<7, id: \.self) { index in
                                let weekdayIndex = (index + calendar.firstWeekday - 1) % 7
                                Text(weekdays[weekdayIndex].capitalized)
                                    .frame(maxWidth: .infinity)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }

                        let days = generateDays(in: currentMonth)

                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 12) {
                            ForEach(days, id: \.self) { date in
                                NavigationLink(
                                    destination: DagDetailView(date: date, onSave: {
                                        refreshID = UUID()
                                    }),
                                    label: {
                                        ZStack(alignment: .topTrailing) {
                                            Circle()
                                                .frame(width: 40, height: 40)
                                                .foregroundColor(getColor(for: date))
                                                .overlay(
                                                    Text("\(calendar.component(.day, from: date))")
                                                        .foregroundColor(.white)
                                                )

                                            if hasBijwerking(for: date) {
                                               
                                                Image(systemName: "message.fill")
                                                    .foregroundColor(.white)
                                                    .font(.caption2)
                                                    .padding(4)
                                                    .background(Color.purple)
                                                    .clipShape(Circle())
                                                    .offset(x: 8, y: -8)
                                            }
                                        }
                                    }
                                )
                                .disabled(date > today)
                            }
                        }
                        .id(refreshID)
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
        }
    }

    func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "nl_BE")
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: date).capitalized
    }

    func changeMonth(by value: Int) {
        if let newDate = calendar.date(byAdding: .month, value: value, to: currentMonth) {
            currentMonth = newDate
        }
    }

    func generateDays(in month: Date) -> [Date] {
        guard let range = calendar.range(of: .day, in: .month, for: month),
              let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: month)) else {
            return []
        }

        let weekdayOfFirst = calendar.component(.weekday, from: startOfMonth)
        let firstWeekday = calendar.firstWeekday
        let prefixEmptyDays = (weekdayOfFirst - firstWeekday + 7) % 7

        var days: [Date?] = Array(repeating: nil, count: prefixEmptyDays)

        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                days.append(date)
            }
        }

        while days.count % 7 != 0 {
            days.append(nil)
        }

        return days.compactMap { $0 }
    }

    func getColor(for date: Date) -> Color {
        let key = calendar.startOfDay(for: date).description
        let value = UserDefaults.standard.object(forKey: key) as? Double

        if date > today {
            return Color.gray.opacity(0.3)
        } else if value == 1 {
            return .green
        } else if value == 0 {
            return .red
        } else {
            return .orange
        }
    }

    func hasBijwerking(for date: Date) -> Bool {
        let bijwerkingenKey = "bijwerkingen_" + calendar.startOfDay(for: date).description
        if let text = UserDefaults.standard.string(forKey: bijwerkingenKey) {
            return !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        return false
    }
}

#Preview {
    KalenderView()
}
