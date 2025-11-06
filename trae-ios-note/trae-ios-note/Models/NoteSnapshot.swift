//
//  NoteSnapshot.swift
//  trae-ios-note
//
//  Created by XIN QI on 2025/11/6.
//

import Foundation

struct NoteSnapshot: Codable, Identifiable {
    var id: UUID
    var title: String
    var content: String
    var lastModified: Date
    var version: Int
    var snapshotDate: Date
    
    init(note: Note, snapshotDate: Date = Date()) {
        self.id = note.id
        self.title = note.title
        self.content = note.content
        self.lastModified = note.lastModified
        self.version = note.version
        self.snapshotDate = snapshotDate
    }
}