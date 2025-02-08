import Foundation
import SwiftUI
import Charts

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

    var aggregatedMoodData: [(date: Date, emoji: String, count: Int)] {
        let moods = moodDataManager.moods
        let calendar = Calendar.current
        let dateComponents = selectedRange.dateComponents
        let endDate = Date()
        let startDate = calendar.date(byAdding: dateComponents, to: endDate) ?? endDate

        let filteredMoods = moods.filter { $0.timestamp >= startDate }

        // Group moods by day, week, or month depending on time range
        let groupedMoods: [Date: [Mood]] = Dictionary(grouping: filteredMoods) { moodEntry in
            switch selectedRange {
            case .day:
                return calendar.startOfDay(for: moodEntry.timestamp)
            case .week:
                return calendar.dateInterval(of: .weekOfYear, for: moodEntry.timestamp)?.start ?? moodEntry.timestamp
            case .month:
                return calendar.dateInterval(of: .month, for: moodEntry.timestamp)?.start ?? moodEntry.timestamp
            case .sixMonths, .year:
                return calendar.dateInterval(of: .month, for: moodEntry.timestamp)?.start ?? moodEntry.timestamp
            }
        }

        // Determine the most common mood for each grouped date
        return groupedMoods.compactMap { (date, moodEntries) in
            let moodCounts = Dictionary(grouping: moodEntries, by: { $0.emoji }).mapValues { $0.count }
            if let mostFrequentMood = moodCounts.max(by: { $0.value < $1.value }) {
                return (date: date, emoji: mostFrequentMood.key, count: mostFrequentMood.value)
            }
            return nil
        }.sorted(by: { $0.date < $1.date })
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Picker("Time Range", selection: $selectedRange) {
                        ForEach(TimeRange.allCases, id: \.self) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .onChange(of: selectedRange) { _ in
                        // Ensure the data updates when the picker value changes
                        _ = aggregatedMoodData
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("AVERAGE")
                            .font(.headline)
                            .foregroundColor(.gray)

                        if let mood = aggregatedMoodData.max(by: { $0.count < $1.count }) {
                            Text("\(mood.emoji) \(mood.count) times")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(moodDataManager.getMoodColor(for: mood.emoji))
                        } else {
                            Text("No data")
                                .font(.title3)
                                .fontWeight(.bold)
                        }

                        Text(dateRange)
                            .fontWeight(.medium)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    if aggregatedMoodData.isEmpty {
                        Text("No mood data for the selected range. Start logging!")
                            .font(.headline)
                            .padding()
                    } else {
                        Chart(aggregatedMoodData, id: \.date) { moodData in
                            BarMark(
                                x: .value("Date", moodData.date, unit: .day),
                                y: .value("Mood Count", moodData.count)
                            )
                            .foregroundStyle(moodDataManager.getMoodColor(for: moodData.emoji))
                            .annotation(position: .top) {
                                Text("\(moodData.count)")
                                    .font(.caption)
                                    .foregroundColor(.black)
                            }
                        }
                        .frame(height: 300)
                        .chartYAxis {
                            AxisMarks(position: .leading)
                        }
                    }

                    VStack(spacing: 10) {
                        if moodDataManager.streak >= 7 {
                            Text("Congratulations! 🎉 You’ve maintained a 7-day streak!")
                                .font(.headline)
                                .foregroundColor(.orange)
                                .padding()
                                .background(Color.yellow.opacity(0.2))
                                .cornerRadius(10)
                        }

                        Text(moodDataManager.getAffirmation())
                            .font(.subheadline)
                            .italic()
                            .foregroundColor(.blue)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(10)
                    }

                    Button(action: {
                        moodDataManager.resetData()
                    }) {
                        Text("Reset Data")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                }
                .padding()
                .navigationTitle("Trends")
            }
        }
    }

    var dateRange: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium

        let endDate = Date()
        let startDate = Calendar.current.date(byAdding: selectedRange.dateComponents, to: endDate) ?? endDate

        return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
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
}
