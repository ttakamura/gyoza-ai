//
//  Item.swift
//  GyozaMic
//
//  Created by Takamura Tatsuya on 2025/07/06.
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
