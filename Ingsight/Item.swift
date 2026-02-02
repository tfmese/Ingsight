//
//  Item.swift
//  Ingsight
//
//  Created by Talha Fırat on 2.02.2026.
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
