import Foundation
import SwiftUICore

class MoodDataManager: ObservableObject {
    @Published var moods: [Mood] = []
    @Published var streak: Int = 0

    private let moodsKey = "moods"

    init() {
        loadMoods()
        calculateStreak()
    }

    func addMood(emoji: String, note: String) {
        let newMood = Mood(id: UUID(), emoji: emoji, note: note, timestamp: Date())
        moods.append(newMood)
        saveMoods()
        calculateStreak()
    }

    private func loadMoods() {
        if let data = UserDefaults.standard.data(forKey: moodsKey),
           let savedMoods = try? JSONDecoder().decode([Mood].self, from: data) {
            moods = savedMoods
        }
    }

    private func saveMoods() {
        if let data = try? JSONEncoder().encode(moods) {
            UserDefaults.standard.set(data, forKey: moodsKey)
        }
    }

    private func calculateStreak() {
        let today = Calendar.current.startOfDay(for: Date())
        var currentStreak = 0

        for (index, mood) in moods.sorted(by: { $0.timestamp > $1.timestamp }).enumerated() {
            let moodDate = Calendar.current.startOfDay(for: mood.timestamp)

            if index == 0 && Calendar.current.isDate(today, inSameDayAs: moodDate) {
                currentStreak += 1
            } else if index > 0 {
                let prevMoodDate = Calendar.current.startOfDay(for: moods[index - 1].timestamp)

                if Calendar.current.isDate(moodDate, inSameDayAs: Calendar.current.date(byAdding: .day, value: -1, to: prevMoodDate)!) {
                    currentStreak += 1
                } else {
                    break
                }
            }
        }

        streak = currentStreak
    }

    func getMoodColor(for emoji: String) -> Color {
        switch emoji {
        case "😀": return .yellow
        case "😢": return .blue
        case "😡": return .red
        case "😴": return .gray
        case "😱": return .purple
        case "😌": return .green
        default: return .black
        }
    }
}
