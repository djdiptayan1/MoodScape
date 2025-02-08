//
//  File.swift
//  My App
//
//  Created by Diptayan Jash on 25/01/25.
//

import Foundation
import SwiftUICore

class MoodDataManager: ObservableObject {
    @Published var moods: [Mood] = []
    @Published var streak: Int = 0

    private let moodsKey = "moods"
    private let streakKey = "streak"

    init() {
        loadMoods()
        loadStreak()
    }

    func addMood(emoji: String, note: String) {
        let newMood = Mood(id: UUID(), emoji: emoji, note: note, timestamp: Date())
        moods.append(newMood)
        saveMoods()
        updateStreak()
    }

    func loadMoods() {
        if let data = UserDefaults.standard.data(forKey: moodsKey),
           let savedMoods = try? JSONDecoder().decode([Mood].self, from: data) {
            moods = savedMoods
        }
    }

    func saveMoods() {
        if let data = try? JSONEncoder().encode(moods) {
            UserDefaults.standard.set(data, forKey: moodsKey)
        }
    }

    func loadStreak() {
        streak = UserDefaults.standard.integer(forKey: streakKey)
    }

    func saveStreak() {
        UserDefaults.standard.set(streak, forKey: streakKey)
    }

    func resetData() {
        moods.removeAll()
        streak = 0
        UserDefaults.standard.removeObject(forKey: moodsKey)
        UserDefaults.standard.removeObject(forKey: streakKey)
    }

    func updateStreak() {
        guard let lastMood = moods.last else {
            return
        }

        let calendar = Calendar.current
        let timezone = TimeZone.current
        let today = calendar.startOfDay(for: Date())
        let localToday = calendar.date(byAdding: .second, value: timezone.secondsFromGMT(for: today), to: today)!
        let lastMoodDate = calendar.startOfDay(for: lastMood.timestamp)

        print("System TimeZone: \(timezone.identifier)")
        print("Today in local time: \(localToday)")
        print("Last Mood Date: \(lastMoodDate)")

        if calendar.isDate(lastMoodDate, inSameDayAs: localToday) {
            print("Mood logged today, no change to streak.")
        } else if calendar.isDate(lastMoodDate, inSameDayAs: calendar.date(byAdding: .day, value: -1, to: localToday)!) {
            streak += 1
            print("Streak incremented: \(streak)")
        } else {
            streak = 1
            print("Streak reset to 1.")
        }

        saveStreak()
    }

    func getMoodColor(for emoji: String) -> Color {
        switch emoji {
        case "😀": return .yellow
        case "😢": return .blue
        case "😡": return .red
        case "😴": return .gray
        case "😱": return .purple
        default: return .black
        }
    }

    func getAffirmation() -> String {
        if let lastMood = moods.last {
            switch lastMood.emoji {
            case "😀": return "Keep up the positive vibes! 🌟"
            case "😢": return "This too shall pass. Take one day at a time. 💙"
            case "😡": return "Take a deep breath and let it go. You’re in control. 🧘‍♀️"
            case "😴": return "Rest is essential. Recharge and conquer! 😌"
            case "😱": return "You’ve got this! Believe in your resilience. 💪"
            default: return "Stay mindful and keep going! 🌈"
            }
        }
        return "Log a mood to see personalized affirmations!"
    }
}
