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
    var errorToReturn: Error? = NSError(domain: "test", code: 1)
    
    func removeAllPendingNotificationRequests() {
        removeAllCallCount += 1
    }
    
    func add(_ request: UNNotificationRequest, completionHandler: ((Error?) -> Void)?) {
        addCallCount += 1
        addedRequests.append(request)
        
        if addCallCount == 2 {
            completionHandler?(errorToReturn)
        } else {
            completionHandler?(nil)
        }
    }
}
