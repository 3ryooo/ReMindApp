//
//  NotificationList.swift
//  ReMindApp
//

import Foundation
import SwiftData

@Model
class NotificationList {
    var id: String
    var content: String
    var notificationDate: Date
    
    init(id: String, content: String, trigger: Date) {
        self.id = id
        self.content = content
        self.notificationDate = trigger
    }
}
