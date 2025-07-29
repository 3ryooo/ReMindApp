//
//  NotificationList.swift
//  ReMindApp
//

import Foundation
import SwiftData

@Model
class NotificationList {
    var id: UUID
    var content: String
    var trigger: Date
    
    init(id: UUID, content: String, trigger: Date) {
        self.id = id
        self.content = content
        self.trigger = trigger
    }
}
