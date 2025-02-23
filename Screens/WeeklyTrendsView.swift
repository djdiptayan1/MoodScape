import Charts
import SwiftUI

struct WeeklyTrendsView: View {
    @EnvironmentObject var moodDataManager: MoodDataManager
    @State private var selectedRange: TimeRange = .week

    enum TimeRange: String, CaseIterable {
        case day = "D"
        case week = "W"
        case month = "M"
        case sixMonths = "6M"
        case year = "Y"
    }

    var body: some View {
        NavigationView {
            VStack {
                Picker("Time Range", selection: $selectedRange) {
                    ForEach(TimeRange.allCases, id: \.self) { range in
                        Text(range.rawValue).tag(range)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                if aggregatedMoodData.isEmpty {
                    Text("No mood data for the selected range.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    Chart {
                        ForEach(aggregatedMoodData, id: \.date) { dataPoint in
                            BarMark(
                                x: .value("Date", dataPoint.date, unit: selectedRange.timeUnit),
                                y: .value("Count", dataPoint.count)
                            )
                            .foregroundStyle(moodDataManager.getMoodColor(for: dataPoint.emoji))
                        }
                    }
                    .chartXAxis {
                        AxisMarks(values: .stride(by: selectedRange.calendarComponent)) { _ in
                            AxisGridLine()
                            AxisValueLabel(format: .dateTime
                                .month(.abbreviated)
                                .day()
                                .hour(.defaultDigits(amPM: .abbreviated)))
                        }
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading) { value in
                            AxisGridLine()
                            AxisValueLabel {
                                if let intValue = value.as(Int.self) {
                                    Text("\(intValue)")
                                }
                            }
                        }
                    }
                    // Remove the fixed domain and let it scale automatically
                    .frame(minHeight: 200, maxHeight: 300)
                    .padding()
//                    .chartYScale(domain: 0 ... (aggregatedMoodData.max(by: { $0.count < $1.count })?.count ?? 0) + 1)
//                    .frame(height: 300)
//                    .padding()
                }
                MoodHistoryView()
            }
            .navigationTitle("Trends")
        }
    }

    // Aggregating mood data based on selected time range
    var aggregatedMoodData: [(date: Date, emoji: String, count: Int)] {
        let moods = moodDataManager.moods
        let calendar = Calendar.current
        guard let startDate = calendar.date(byAdding: selectedRange.dateComponents, to: Date()) else {
            return []
        }

        let filteredMoods = moods.filter { $0.timestamp >= startDate }

        // Group moods based on the selected time interval
        let groupedMoods: [Date: [Mood]] = Dictionary(grouping: filteredMoods) { mood in
            switch selectedRange {
            case .day:
                return calendar.startOfDay(for: mood.timestamp)
            case .week:
                return calendar.dateInterval(of: .weekOfYear, for: mood.timestamp)?.start ?? mood.timestamp
            case .month:
                return calendar.dateInterval(of: .month, for: mood.timestamp)?.start ?? mood.timestamp
            case .sixMonths, .year:
                return calendar.dateInterval(of: .month, for: mood.timestamp)?.start ?? mood.timestamp
            }
        }

        // Aggregate data by counting the most common moods per date
        return groupedMoods.compactMap { date, moods in
            let moodCounts = Dictionary(grouping: moods, by: { $0.emoji }).mapValues { $0.count }
            if let mostCommonMood = moodCounts.max(by: { $0.value < $1.value }) {
                return (date: date, emoji: mostCommonMood.key, count: mostCommonMood.value)
            }
            return nil
        }.sorted(by: { $0.date < $1.date })
    }

    // Format date for displaying on the chart based on the selected range
    func formattedDate(_ date: Date, for range: TimeRange) -> String {
        let formatter = DateFormatter()
        switch range {
        case .day:
            formatter.dateFormat = "h a" // Hour format (e.g., "2 PM")
        case .week:
            formatter.dateFormat = "E" // Day of the week (e.g., "Mon")
        case .month, .sixMonths, .year:
            formatter.dateFormat = "MMM d" // Month and day (e.g., "Feb 8")
        }
        return formatter.string(from: date)
    }
}

extension WeeklyTrendsView.TimeRange {
    var dateComponents: DateComponents {
        switch self {
        case .day: return DateComponents(day: -1)
        case .week: return DateComponents(day: -7)
        case .month: return DateComponents(month: -1)
        case .sixMonths: return DateComponents(month: -6)
        case .year: return DateComponents(year: -1)
        }
    }

    var timeUnit: Calendar.Component {
        switch self {
        case .day: return .hour
        case .week: return .day
        case .month, .sixMonths, .year: return .month
        }
    }

    var calendarComponent: Calendar.Component {
        switch self {
        case .day: return .hour
        case .week: return .day
        case .month: return .month
        case .sixMonths: return .month
        case .year: return .month
        }
    }
}
