//
//  MoodTrackerView.swift
//  MoodScape
//
//  Created by Diptayan Jash on 25/01/25.
//

import SwiftUI

struct MoodTrackerView: View {
    @EnvironmentObject var moodDataManager: MoodDataManager
    @State private var selectedEmoji: String? = nil
    @State private var moodNote: String = ""
    @State private var streak: Int = 0
    @State private var customEmojis: [String] = ["😀", "😢", "😡", "😴", "😱"]
    @State private var showEmojiPicker = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    EmojiSelectorView(
                        selectedEmoji: $selectedEmoji,
                        customEmojis: $customEmojis,
                        showEmojiPicker: $showEmojiPicker
                    )
                    
                    MoodNoteView(moodNote: $moodNote)
                    
                    SubmitButton(
                        selectedEmoji: selectedEmoji,
                        moodNote: moodNote,
                        streak: $streak,
                        onMoodSubmit: {
                            if let emoji = selectedEmoji {
                                moodDataManager.addMood(emoji: emoji, note: moodNote)
                                updateStreak()
                                moodNote = ""
                                selectedEmoji = nil
                            }
                        }
                    )
                    
                    if let recentMood = moodDataManager.moods.last {
                        RecentMoodView(mood: recentMood, streak: streak)
                    }
                }
                .padding()
            }
            .navigationTitle("How are you feeling?")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showEmojiPicker) {
            EmojiPickerView(customEmojis: $customEmojis, isPresented: $showEmojiPicker)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .onAppear {
            if let savedEmojis = UserDefaults.standard.array(forKey: "customEmojis") as? [String] {
                customEmojis = savedEmojis
            }
        }
        .onChange(of: customEmojis) { newValue in
            UserDefaults.standard.set(newValue, forKey: "customEmojis")
        }
    }

    private func updateStreak() {
        let today = Calendar.current.startOfDay(for: Date())
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today) ?? Date()

        if let lastMood = moodDataManager.moods.last, Calendar.current.isDate(lastMood.timestamp, inSameDayAs: yesterday) {
            streak += 1
        } else if moodDataManager.moods.last?.timestamp != nil {
            streak = 1
        }
    }
}
