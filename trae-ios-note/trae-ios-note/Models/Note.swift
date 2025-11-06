//
//  Note.swift
//  trae-ios-note
//
//  Created by XIN QI on 2025/11/6.
//

import Foundation
import SwiftData

@Model
final class Note {
    var id: UUID
    var title: String
    var content: String
    var lastModified: Date
    var version: Int
    var isConflict: Bool
    
    init(title: String = "", content: String = "", lastModified: Date = Date(), version: Int = 1, isConflict: Bool = false) {
        self.id = UUID()
        self.title = title
        self.content = content
        self.lastModified = lastModified
        self.version = version
        self.isConflict = isConflict
    }
}