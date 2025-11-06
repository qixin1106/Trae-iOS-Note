//
//  Item.swift
//  trae-ios-note
//
//  Created by XIN QI on 2025/11/6.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
