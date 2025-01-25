//
//  MoodModel.swift
//  My App
//
//  Created by Diptayan Jash on 25/01/25.
//

import Foundation

struct Mood: Codable, Identifiable {
    let id: UUID
    let emoji: String
    let note: String
    let timestamp: Date
}
