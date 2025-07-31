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
    var notificationDate: Date
    
    init(id: UUID, content: String, trigger: Date) {
        self.id = id
        self.content = content
        self.notificationDate = trigger
    }
}
