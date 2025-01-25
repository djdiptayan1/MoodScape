//
//  EmojiDropDelegate.swift
//  MoodScape
//
//  Created by Diptayan Jash on 26/01/25.
//

import Foundation

import SwiftUI

struct EmojiDropDelegate: DropDelegate {
    let item: String
    let fromIndex: Int
    @Binding var emojis: [String]
    @Binding var draggedEmojiIndex: Int?

    func dropEntered(info: DropInfo) {
        guard let draggedIndex = draggedEmojiIndex, draggedIndex != fromIndex else { return }

        // Perform reordering
        withAnimation {
            let draggedItem = emojis.remove(at: draggedIndex)
            emojis.insert(draggedItem, at: fromIndex)
            draggedEmojiIndex = fromIndex
        }
    }

    func performDrop(info: DropInfo) -> Bool {
        draggedEmojiIndex = nil
        return true
    }
}
