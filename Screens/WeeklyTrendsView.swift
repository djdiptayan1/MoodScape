//
//  File.swift
//  MoodScape
//
//  Created by Diptayan Jash on 25/01/25.
//

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

    var filteredData: [String: Int] {
        let startDate = Calendar.current.date(byAdding: selectedRange.dateComponents, to: Date()) ?? Date()
        let filteredMoods = moodDataManager.moods.filter { $0.timestamp >= startDate }
        return Dictionary(grouping: filteredMoods, by: { $0.emoji }).mapValues { $0.count }
    }

    var mostUsedMood: (emoji: String, count: Int)? {
        if let maxElement = filteredData.max(by: { $0.value < $1.value }) {
            return (emoji: maxElement.key, count: maxElement.value)
        }
        return nil
    }

    var dateRange: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium

        let endDate = Date()
        let startDate = Calendar.current.date(byAdding: selectedRange.dateComponents, to: endDate) ?? Date()

        return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Picker("Time Range", selection: $selectedRange) {
                        ForEach(TimeRange.allCases, id: \..self) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())

                    VStack(alignment: .leading, spacing: 10) {
                        Text("AVERAGE")
                            .font(.headline)
                            .foregroundColor(.gray)

                        if let mood = mostUsedMood {
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

                    if filteredData.isEmpty {
                        Text("No mood data for the selected range. Start logging!")
                            .font(.headline)
                            .padding()
                    } else {
                        Chart(filteredData.sorted(by: { $0.key < $1.key }), id: \..key) { emoji, count in
                            BarMark(
                                x: .value("Mood", emoji),
                                y: .value("Count", count)
                            )
                            .foregroundStyle(moodDataManager.getMoodColor(for: emoji))
                        }
                        .frame(height: 300)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                        .shadow(radius: 5)
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
