//
//  NotificationStore.swift
//  ReMindApp
//

import Foundation
import SwiftData
import Observation
import UserNotifications

@Observable
class NotificationStore {
    
    // MARK: - プロパティ
    private let scheduler: NotificationScheduling
    
    // TODO: プロトコル化（20251113_1850_17）
    var isNotificationEnabled = UserDefaults.standard.bool(forKey: AppConstants.UserDefaultsKeys.isNotificationEnabled)
    var isRandomTimeEnabled = UserDefaults.standard.bool(forKey: AppConstants.UserDefaultsKeys.isRandomTimeEnabled)
    var selectedFrequency = UserDefaults.standard.integer(forKey: AppConstants.UserDefaultsKeys.frequencyKey)
    var countForReviewRequest = UserDefaults.standard.integer(forKey: AppConstants.UserDefaultsKeys.countForReviewRequest)
    var baseTime = UserDefaults.standard.object(forKey: AppConstants.UserDefaultsKeys.baseTime) as? Date ?? Date()
    
    var showingAuthorizationAlert = false
    var showingNotificationErrorAlert = false
    var notificationErrorMessage = ""
    
    init(scheduler: NotificationScheduling = DefaultNotificationScheduler()) {
        self.scheduler = scheduler
        if UserDefaults.standard.object(forKey: AppConstants.UserDefaultsKeys.baseTime) == nil {
            baseTime = Date()
            UserDefaults.standard.set(baseTime, forKey: AppConstants.UserDefaultsKeys.baseTime)
        }
    }
    
    private var isDailyFrequency: Bool {
        selectedFrequency >= 24
    }

//  TODO: （待ち）本番用の値に変更（現在はテスト用で少なめ）
    private let lastNotificationId = AppConstants.notificationCount
    
    
    // MARK: - 通知（認証）
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            #if DEBUG
            if success {
                print("許可")
            } else if let error = error {
                print("失敗：\(error.localizedDescription)")
            }
            #endif
            
            if !success {
                DispatchQueue.main.async {
                    self.showingAuthorizationAlert = true
                }
            }
            
        }
    }
    
    // MARK: - 設定保存
    func saveSettings() {
        
        countForReviewRequest += 1

        UserDefaults.standard.set(isNotificationEnabled, forKey: AppConstants.UserDefaultsKeys.isNotificationEnabled)
        UserDefaults.standard.set(isRandomTimeEnabled, forKey: AppConstants.UserDefaultsKeys.isRandomTimeEnabled)
        UserDefaults.standard.set(selectedFrequency, forKey: AppConstants.UserDefaultsKeys.frequencyKey)
        UserDefaults.standard.set(baseTime, forKey: AppConstants.UserDefaultsKeys.baseTime)
        UserDefaults.standard.set(countForReviewRequest, forKey: AppConstants.UserDefaultsKeys.countForReviewRequest)
    }
    
    // MARK: - リマインド設定
    
    // TODO: コード分割（20251112_1745_29）
    func setNotificationList(for items: [ReminderItem]) {
        // エラー状態をリセット
        showingNotificationErrorAlert = false
        notificationErrorMessage = ""
        
        if !isNotificationEnabled {
            removeAllNotification()
            return
        }
        
        // 基準日時の作成をテスト
        guard getFirstNotificationDate() != nil else {
            DispatchQueue.main.async {
                self.notificationErrorMessage = "通知の設定に失敗しました。時刻設定を確認してください。"
                self.showingNotificationErrorAlert = true
            }
            return
        }
        
        removeAllNotification()
        
        var failedCount = 0
        for i in 1...lastNotificationId {
            if !createNotification(i, items: items) {
                failedCount += 1
            }
        }
        
        // 一部の通知設定に失敗した場合の警告
        if failedCount > 0 {
            DispatchQueue.main.async {
                self.notificationErrorMessage = "一部の通知設定に失敗しました（\(failedCount)件）。アプリを再起動してお試しください。"
                self.showingNotificationErrorAlert = true
            }
        }
        
    }
    
    func removeAllNotification() {
        scheduler.removeAllPendingNotificationRequests()
        #if DEBUG
        print("通知全消去")
        #endif
    }
    
    private func createNotification(_ id : Int, items: [ReminderItem]) -> Bool {
        let item = getNotifiedItem(items: items)
        
        guard let firstNotificationDate = getFirstNotificationDate() else {
            #if DEBUG
            print("通知の基準日時の作成に失敗しました。通知ID: \(id)")
            #endif
            return false
        }
        
        guard let notificationDate = notificationTimeConverter(firstNotificationDate, id) else {
            #if DEBUG
            print("通知の基準日時のコンバートに失敗しました。通知ID: \(id)")
            #endif
            return false
        }
        
        let originID = UUID().uuidString
        
        let content = UNMutableNotificationContent()
        content.title = "Re:Mind"
        content.body = id == lastNotificationId ? "\(item)\n通知の上限に達しました。設定より再度「保存」をタップしてください" : item
        content.sound = .default
         
        
        let component = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: notificationDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: component, repeats: false)
        let request = UNNotificationRequest(identifier: originID, content: content, trigger: trigger)
        
        scheduler.add(request) { error in
            if let error = error {
                #if DEBUG
                print("スケジューリング失敗：\(error.localizedDescription)")
                #endif
                DispatchQueue.main.async {
                    self.notificationErrorMessage = "通知のスケジューリングに失敗しました。アプリを再起動してお試しください。"
                    self.showingNotificationErrorAlert = true
                }
            } else {
                #if DEBUG
                let japanTime = DateConverter().japanTime(notificationDate)
                print("スケジューリング成功： id:\(id) 通知予定：\(japanTime)")
                #endif
            }
        }
        return true
    }
    
    private func getNotifiedItem(items: [ReminderItem]) -> String {
        let notifiedTexts = items.compactMap { $0.isNotificationEnable ? $0.text : nil }
        
        if let randomText = notifiedTexts.randomElement() {
            return randomText
        } else {
            return "リストが空です"
        }
    }
    
    private func getFirstNotificationDate() -> Date? {
        let now = Date()
        let calendar = Calendar(identifier: .gregorian)
        
        let year = calendar.component(.year, from: now)
        let month = calendar.component(.month, from: now)
        let day = calendar.component(.day, from: now)
        
        let hour = calendar.component(.hour, from: self.baseTime)
        let minute = calendar.component(.minute, from: self.baseTime)
        
        guard var firstDate = calendar.date(from: DateComponents(
            year: year, 
            month: month, 
            day: day, 
            hour: hour, 
            minute: minute, 
            second: 0
        )) else {
            return nil
        }
        
        while firstDate <= now {
            firstDate = firstDate.addingTimeInterval(TimeInterval(60 * 60 * selectedFrequency))
        }
        
        return firstDate
    }
    
    private func notificationTimeConverter(_ setDate: Date, _ id: Int) -> Date? {
        let notificationDate = setDate.addingTimeInterval(TimeInterval(60 * 60 * selectedFrequency * id)) // 本番用
        
        let calendar = Calendar(identifier: .gregorian)
        
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: notificationDate)
        
        if isRandomTimeEnabled && isDailyFrequency {
            components.hour = Int.random(in: 0..<24)
            components.minute = Int.random(in: 0..<59)
        }
        
        return calendar.date(from: components)
           
    }

    
}
