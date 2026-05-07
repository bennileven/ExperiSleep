//
//  Item.swift
//  ExperiSleep
//
//  Created by benni leven on 07.05.26.
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
