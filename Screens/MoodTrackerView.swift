import SwiftUI

struct MoodTrackerView: View {
    @EnvironmentObject var moodDataManager: MoodDataManager
    @State private var selectedEmoji: String? = nil
    @State private var moodNote: String = ""

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Emoji Mood Selector
                    EmojiSelectorView(selectedEmoji: $selectedEmoji)

                    // Mood Note Section
                    MoodNoteView(moodNote: $moodNote)

                    // Submit Button
                    Button(action: submitMood) {
                        Text("Submit Mood")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(selectedEmoji == nil ? Color.gray : Color.blue)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                    .disabled(selectedEmoji == nil)

                    // Recent Mood View
                    if let recentMood = moodDataManager.moods.last {
                        RecentMoodView(mood: recentMood, streak: moodDataManager.streak)
                    }
                }
                .padding()
            }
            .navigationTitle("How are you feeling?")
        }
    }

    private func submitMood() {
        if let emoji = selectedEmoji {
            moodDataManager.addMood(emoji: emoji, note: moodNote)
            moodNote = ""
            selectedEmoji = nil
        }
    }
}
