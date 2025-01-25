//
//  File.swift
//  MoodScape
//
//  Created by Diptayan Jash on 26/01/25.
//

import Foundation
import SwiftUI

struct MoodNoteView: View {
    @Binding var moodNote: String

    var body: some View {
        TextField("Add a note to your mood (optional)...", text: $moodNote)
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
            )
            .padding()
    }
}
