//
//  NotificationManager.swift
//  ReMindApp
//

import Foundation
import UserNotifications
import UIKit

class NotificationManager {
    func openAppSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
}
