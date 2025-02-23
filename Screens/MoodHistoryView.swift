//
//  File.swift
//  MoodScape
//
//  Created by Diptayan Jash on 23/02/25.
//

import Foundation
import SwiftUI
struct MoodHistoryView: View {
    @EnvironmentObject var moodDataManager: MoodDataManager
    @State private var isExpanded = false
    
    var body: some View {
        VStack {
            Button(action: {
                withAnimation {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Text("Mood History")
                        .font(.headline)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                }
                .padding()
                .background(Color(.systemBackground))
            }
            
            if isExpanded {
                List {
                    ForEach(moodDataManager.moods.sorted(by: { $0.timestamp > $1.timestamp })) { mood in
                        MoodHistoryRow(mood: mood)
                    }
                }
                .listStyle(PlainListStyle())
                .frame(maxHeight: 300)
            }
        }
        .background(Color(.systemGroupedBackground))
        .cornerRadius(10)
        .padding()
    }
}

struct MoodHistoryRow: View {
    let mood: Mood
    
    var body: some View {
        HStack {
            Text(mood.emoji)
                .font(.title)
            VStack(alignment: .leading) {
                Text(formatDate(mood.timestamp))
                    .font(.caption)
                    .foregroundColor(.secondary)
                if !mood.note.isEmpty {
                    Text(mood.note)
                        .font(.body)
                        .padding(.top, 2)
                }
            }
            Spacer()
        }
        .padding(.vertical, 8)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
