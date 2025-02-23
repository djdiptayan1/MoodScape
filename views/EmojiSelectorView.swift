import SwiftUI

struct EmojiSelectorView: View {
    @Binding var selectedEmoji: String?
    let emojis = ["😀", "😢", "😡", "😴", "😱", "😌"]

    var body: some View {
        LazyVGrid(columns: [GridItem(), GridItem(), GridItem()], spacing: 20) {
            ForEach(emojis, id: \.self) { emoji in
                Text(emoji)
                    .font(.largeTitle)
                    .padding()
                    .background(selectedEmoji == emoji ? Color.blue.opacity(0.3) : Color.clear)
                    .clipShape(Circle())
                    .onTapGesture {
                        selectedEmoji = emoji
                    }
            }
        }
        .padding()
    }
}
