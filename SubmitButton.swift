//
//  File.swift
//  MoodScape
//
//  Created by Diptayan Jash on 26/01/25.
//

import Foundation
import SwiftUI

import SwiftUI

struct SubmitButton: View {
    var selectedEmoji: String?
    var moodNote: String
    @Binding var streak: Int
    var onMoodSubmit: () -> Void

    var body: some View {
        Button(action: {
            if let _ = selectedEmoji {
                onMoodSubmit()
            }
        }) {
            Text("Submit")
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(selectedEmoji == nil ? Color.gray : Color.blue)
                .cornerRadius(10)
                .shadow(radius: 5)
        }
        .disabled(selectedEmoji == nil)
    }

    private func updateStreak() {
        let today = Calendar.current.startOfDay(for: Date())
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today) ?? Date()
        // Streak update logic here
    }
}
