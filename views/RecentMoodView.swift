//
//  File.swift
//  MoodScape
//
//  Created by Diptayan Jash on 26/01/25.
//

import Foundation
import SwiftUI

struct RecentMoodView: View {
    let mood: Mood
    let streak: Int

    var body: some View {
        VStack(spacing: 10) {
            Text("You last felt \(mood.emoji) - \(mood.note.isEmpty ? "No note added" : mood.note)")
                .font(.headline)
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(radius: 5)

            Text("Motivation: Stay positive, you're doing great!")
                .font(.subheadline)
                .foregroundColor(.green)

            HStack {
                Image(systemName: "flame.fill")
                    .font(.largeTitle)
                    .foregroundColor(.orange)
                Text("Streak: \(streak) days")
                    .font(.headline)
                    .foregroundColor(.orange)
                    .bold()
            }
        }
        .padding()
    }
}
