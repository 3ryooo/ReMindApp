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
    private let userDefaults: UserDefaultsProtocol
    private let timeProvider: TimeProvider
    
    var appNotificationEnabled: Bool
    var isRandomTimeEnabled: Bool
    var selectedFrequency: Int
    var countForReviewRequest: Int
    var baseTime: Date
    
    var showingAuthorizationAlert = false
    var showingNotificationErrorAlert = false
    var notificationErrorMessage = ""
    
    init(
        scheduler: NotificationScheduling = DefaultNotificationScheduler(),
        userDefaults: UserDefaultsProtocol = UserDefaults.standard,
        timeProvider: TimeProvider = DefaultTimeProvider()
    ) {
        self.scheduler = scheduler
        self.userDefaults = userDefaults
        self.timeProvider = timeProvider
        
        // UserDefaultsから初期値を読み込み
        self.appNotificationEnabled = userDefaults.bool(forKey: AppConstants.UserDefaultsKeys.appNotificationEnabled)
        self.isRandomTimeEnabled = userDefaults.bool(forKey: AppConstants.UserDefaultsKeys.isRandomTimeEnabled)
        self.selectedFrequency = userDefaults.integer(forKey: AppConstants.UserDefaultsKeys.frequencyKey)
        self.countForReviewRequest = userDefaults.integer(forKey: AppConstants.UserDefaultsKeys.countForReviewRequest)
        
        if let savedBaseTime = userDefaults.object(forKey: AppConstants.UserDefaultsKeys.baseTime) as? Date {
            self.baseTime = savedBaseTime
        } else {
            self.baseTime = timeProvider.now()
            userDefaults.set(baseTime, forKey: AppConstants.UserDefaultsKeys.baseTime)
        }
    }
    
    private var isDailyFrequency: Bool {
        selectedFrequency >= 24
    }

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

        userDefaults.set(appNotificationEnabled, forKey: AppConstants.UserDefaultsKeys.appNotificationEnabled)
        userDefaults.set(isRandomTimeEnabled, forKey: AppConstants.UserDefaultsKeys.isRandomTimeEnabled)
        userDefaults.set(selectedFrequency, forKey: AppConstants.UserDefaultsKeys.frequencyKey)
        userDefaults.set(baseTime, forKey: AppConstants.UserDefaultsKeys.baseTime)
        userDefaults.set(countForReviewRequest, forKey: AppConstants.UserDefaultsKeys.countForReviewRequest)
    }
    
    // MARK: - リマインド設定
    
    func setNotificationList(for items: [ReminderItem]) {
        resetErrorState()
        
        guard appNotificationEnabled else {
            removeAllNotification()
            return
        }
        
        guard validateNotificationSettings() else {
            return
        }
        
        removeAllNotification()
        let failedCount = createAllNotifications(for: items)
        handleNotificationErrors(failedCount: failedCount)
    }
    
    private func resetErrorState() {
        showingNotificationErrorAlert = false
        notificationErrorMessage = ""
    }
    
    private func validateNotificationSettings() -> Bool {
        guard getFirstNotificationDate() != nil else {
            showError("通知の設定に失敗しました。時刻設定を確認してください。")
            return false
        }
        return true
    }
    
    private func createAllNotifications(for items: [ReminderItem]) -> Int {
        var failedCount = 0
        for i in 1...lastNotificationId {
            if !createNotification(i, items: items) {
                failedCount += 1
            }
        }
        return failedCount
    }
    
    private func handleNotificationErrors(failedCount: Int) {
        if failedCount > 0 {
            showError("一部の通知設定に失敗しました（\(failedCount)件）。アプリを再起動してお試しください。")
        }
    }
    
    private func showError(_ message: String) {
        DispatchQueue.main.async {
            self.notificationErrorMessage = message
            self.showingNotificationErrorAlert = true
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
    func getNotifiedItem(items: [ReminderItem]) -> String {
        let notifiedTexts = items.compactMap { $0.itemNotificationEnabled ? $0.text : nil }
        
        if let randomText = notifiedTexts.randomElement() {
            return randomText
        } else {
            return "リストが空です"
        }
    }
    
    func getFirstNotificationDate() -> Date? {
        let now = timeProvider.now()
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
    
    func notificationTimeConverter(_ setDate: Date, _ id: Int) -> Date? {
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
