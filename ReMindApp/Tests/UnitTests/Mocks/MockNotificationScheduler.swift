//
//  MockNotificationScheduler.swift
//  ReMindAppTests
//

import Foundation
import UserNotifications

class MockNotificationScheduler: NotificationScheduling {
    
    var removeAllCallCount = 0
    var addCallCount = 0
    
    var addedRequests: [UNNotificationRequest] = []
    
    func removeAllPendingNotificationRequests() {
        removeAllCallCount += 1
    }
    
    func add(_ request: UNNotificationRequest, completionHandler: ((Error?) -> Void)?) {
        addCallCount += 1
        addedRequests.append(request)
        completionHandler?(nil)  // エラーなしで完了
    }
}
