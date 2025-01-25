//
//  File.swift
//  MoodScape
//
//  Created by Diptayan Jash on 26/01/25.
//

import Foundation
import SwiftUI

struct EmojiPickerView: View {
    @Binding var customEmojis: [String]
    @Binding var isPresented: Bool

    var body: some View {
        VStack(spacing: 20) {
            Text("Pick an Emoji")
                .font(.headline)
                .fontWeight(.bold)
                .padding()

            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 5), spacing: 20) {
                    ForEach(generateEmojis(), id: \.self) { emoji in
                        Button(action: {
                            if !customEmojis.contains(emoji) {
                                customEmojis.append(emoji)
                            }
                            isPresented = false
                        }) {
                            Text(emoji)
                                .font(.system(size: 50))
                                .frame(width: 60, height: 60)
                        }
                    }
                }
            }
            .padding()

            Button("Close") {
                isPresented = false
            }
            .foregroundColor(.red)
        }
//        .padding()
    }

    private func generateEmojis() -> [String] {
        var emojis: [String] = []
        let emojiRanges: [(Int, Int)] = [
            (0x1F600, 0x1F64F), // Emoticons
            (0x1F300, 0x1F5FF), // Misc Symbols and Pictographs
            (0x1F680, 0x1F6FF), // Transport and Map Symbols
            (0x1F700, 0x1F77F), // Alchemical Symbols
            (0x1F780, 0x1F7FF), // Geometric Shapes Extended
            (0x1F800, 0x1F8FF), // Supplemental Arrows-C
            (0x1F900, 0x1F9FF), // Supplemental Symbols and Pictographs
            (0x1FA00, 0x1FAFF), // Chess Symbols
            (0x2600, 0x26FF), // Miscellaneous Symbols
            (0x2700, 0x27BF), // Dingbats
            (0x1F1E6, 0x1F1FF), // Regional Indicator Symbols
        ]

        for range in emojiRanges {
            for codePoint in range.0 ... range.1 {
                if let scalar = UnicodeScalar(codePoint), scalar.properties.isEmoji {
                    emojis.append(String(scalar))
                }
            }
        }

        return emojis
    }
}
