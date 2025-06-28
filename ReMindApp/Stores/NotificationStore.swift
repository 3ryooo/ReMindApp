//
//  NotificationStore.swift
//  ReMindApp
//

import Foundation
import Observation
import UserNotifications

@Observable
class NotificationStore {
    var isNotificationEnabled = UserDefaults.standard.bool(forKey: "isNotificationEnabled")
    var selectedFrequency = UserDefaults.standard.integer(forKey: "frequencyKey")
    var baseTime = UserDefaults.standard.object(forKey: "baseTime") as? Date ?? Date() // TODO:二重になっているので修正する
    var showingAuthorizationAlert = false
    
    //    テスト中のため数を少なめに設定
    private let lastNotificationId = 5
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("許可")
            } else if let error = error {
                print("失敗：\(error.localizedDescription)")
            }
            
            if !success {
                DispatchQueue.main.async {
                    self.showingAuthorizationAlert = true
                }
            }
            
        }
    }
    
    func saveSettings() {
        UserDefaults.standard.set(isNotificationEnabled, forKey: "isNotificationEnabled")
        UserDefaults.standard.set(selectedFrequency, forKey: "frequencyKey")
        UserDefaults.standard.set(baseTime, forKey: "baseTime")
    }
    
    func setNotificationList(for items: [ReminderItem]) {
        
        removeAllNotification()
        
        for i in 1...lastNotificationId {
            setNotification(i, items: items)
        }
        
    }
    
    func removeAllNotification() {
        //        トリガーは保存時のみ？→長期的なリマインドが毎回消えてしまう
        let lcNotification = UNUserNotificationCenter.current()
        lcNotification.removeAllPendingNotificationRequests()
        print("通知全消去")
    }
    
    private func setNotification(_ id : Int, items: [ReminderItem]) {
        
        
        let notifiedItems = items.filter { $0.isNotificationEnable == true }
        //        TODO:個別のリマインダーをON・OFFしたときにスケジュールを残したまま対象のアイテムを変更する方法
        var textRange: Int {
            if notifiedItems.count > 0 {
                return notifiedItems.count
            } else {
                return 1
            }
        }
        
        var remindTexts: [String] = []
        
        if notifiedItems.count > 0 {
            for i in notifiedItems {
                remindTexts.append(i.text)
            }
        } else {
            remindTexts.append("リストが空です")
        }
        
        let randomNumber = Int.random(in: 0..<textRange)
        
        
        let content = UNMutableNotificationContent()
        content.title = "Re:Mind" // ランダムで作成？
        content.body = remindTexts[randomNumber]
        
        if id == lastNotificationId {
            content.body = "\(remindTexts[randomNumber])\n通知の上限に達しました。設定より再度「保存」をタップしてください"
        }
        
        
        
        content.sound = .default
        
        let date = Date()
        //        let newDate = Date(timeInterval: TimeInterval(60 * 60 * id), since: date)
        
        //        テスト用
        let newDate = Date(timeInterval: TimeInterval(60 * id), since: date)
        
        
        let component = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: newDate)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: component, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("スケジューリング失敗：\(error.localizedDescription)")
            } else {
                print("スケジューリング成功： id:\(id) 通知予定：\(newDate)")
            }
        }
    }
    
}
