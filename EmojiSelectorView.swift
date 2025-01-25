//
//  EmojiSelectorView.swift
//  MoodScape
//

import SwiftUI
import UniformTypeIdentifiers

struct EmojiSelectorView: View {
    @Binding var selectedEmoji: String?
    @Binding var customEmojis: [String]
    @Binding var showEmojiPicker: Bool
    @State private var isEditing = false
    @State private var draggedEmojiIndex: Int? = nil

    var body: some View {
        VStack {
            if isEditing {
                Text("Drag to rearrange or tap 'Done' to finish editing.")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.bottom, 10)
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 3), spacing: 20) {
                ForEach(customEmojis.indices, id: \.self) { index in
                    let emoji = customEmojis[index]

                    Text(emoji)
                        .font(.system(size: 60))
                        .frame(width: 80, height: 80)
                        .background(
                            Circle()
                                .fill(selectedEmoji == emoji ? Color.blue : Color.blue.opacity(0.2))
                        )
                        .scaleEffect(selectedEmoji == emoji ? 1.1 : 1.0)
                        .animation(.spring(), value: selectedEmoji)
                        .onTapGesture {
                            if selectedEmoji == emoji {
                                selectedEmoji = nil
                            } else {
                                selectedEmoji = emoji
                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                generator.impactOccurred()
                            }
                        }
                        .gesture(
                            LongPressGesture(minimumDuration: 0.5).onEnded { _ in
                                isEditing = true
                            }
                        )
                        .onDrag {
                            draggedEmojiIndex = index
                            return NSItemProvider(object: NSString(string: emoji))
                        }
                        .onDrop(of: [UTType.text], delegate: EmojiDropDelegate(
                            item: emoji,
                            fromIndex: index,
                            emojis: $customEmojis,
                            draggedEmojiIndex: $draggedEmojiIndex
                        ))
                        .overlay(
                            isEditing ? deleteButtonOverlay(for: index) : nil
                        )
                }

                // "Add More Emoji" Button
                Button(action: {
                    showEmojiPicker.toggle()
                }) {
                    VStack {
                        Image(systemName: "plus.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.green)
                        Text("Add More")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                    .frame(width: 80, height: 80)
                    .background(Circle().fill(Color.green.opacity(0.2)))
                }
            }
            .padding()

            if isEditing {
                Button("Done") {
                    isEditing = false
                }
                .font(.headline)
                .padding()
                .foregroundColor(.blue)
            }
        }
    }

    private func deleteButtonOverlay(for index: Int) -> some View {
        Button(action: {
            customEmojis.remove(at: index)
        }) {
            Image(systemName: "trash.fill")
                .foregroundColor(.red)
                .frame(width: 30, height: 30)
                .background(Circle().fill(Color.white))
                .shadow(radius: 3)
        }
        .offset(x: -30, y: -30)
    }
}
