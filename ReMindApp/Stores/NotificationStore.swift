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
    var isNotificationEnabled = UserDefaults.standard.bool(forKey: "isNotificationEnabled")
    var isRandomTimeEnabled = UserDefaults.standard.bool(forKey: "isRandomTimeEnabled")
    var selectedFrequency = UserDefaults.standard.integer(forKey: "frequencyKey")
    var countForReviewRequest = UserDefaults.standard.integer(forKey: "countForReviewRequest")
    var baseTime = UserDefaults.standard.object(forKey: "baseTime") as? Date ?? Date()
    
    var showingAuthorizationAlert = false
    var showingNotificationErrorAlert = false
    var notificationErrorMessage = ""
    
    enum FrequencyMode: String {case h1, h3, h6, h9, h12, d1, d2, d3, d5, w1, w2, m1, m3, m6, y1}
    
    init(scheduler: NotificationScheduling = DefaultNotificationScheduler()) {
        self.scheduler = scheduler
        if UserDefaults.standard.object(forKey: "baseTime") == nil {
            baseTime = Date()
            UserDefaults.standard.set(baseTime, forKey: "baseTime")
        }
    }
    

//  TODO: （待ち）本番用の値に変更（現在はテスト用で少なめ）
    private let lastNotificationId = 5
    
    
    // MARK: - 通知（認証）
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
    
    // MARK: - 設定保存
    func saveSettings() {
        
        countForReviewRequest += 1

        UserDefaults.standard.set(isNotificationEnabled, forKey: "isNotificationEnabled")
        UserDefaults.standard.set(isRandomTimeEnabled, forKey: "isRandomTimeEnabled")
        UserDefaults.standard.set(selectedFrequency, forKey: "frequencyKey")
        UserDefaults.standard.set(baseTime, forKey: "baseTime")
        UserDefaults.standard.set(countForReviewRequest, forKey: "countForReviewRequest")
    }
    
    // MARK: - リマインド設定
    
    
    private func setNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: <#T##[String]#>)
    }
    
    
    
    func setNotificationList(for items: [ReminderItem], context: ModelContext) {
        // エラー状態をリセット
        showingNotificationErrorAlert = false
        notificationErrorMessage = ""
        
        // 基準日時の作成をテスト
        guard getFirstNotificationDate() != nil else {
            DispatchQueue.main.async {
                self.notificationErrorMessage = "通知の設定に失敗しました。時刻設定を確認してください。"
                self.showingNotificationErrorAlert = true
            }
            return
        }
        
        removeAllNotification(context)
        
        var failedCount = 0
        for i in 1...lastNotificationId {
            if !createNotification(i, items: items, context: context) {
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
    
    func removeAllNotification(_ context: ModelContext) {
        //        トリガーは保存時のみ？→長期的なリマインドが毎回消えてしまう
        scheduler.removeAllPendingNotificationRequests()
        do {
            let existingNotifications = try context.fetch(FetchDescriptor<NotificationList>())
            
            for notification in existingNotifications {
                context.delete(notification)
            }
            
            try context.save()
            
        } catch {
            print("error: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.notificationErrorMessage = "通知の削除に失敗しました。アプリを再起動してお試しください。"
                self.showingNotificationErrorAlert = true
            }
        }
        
        print("通知全消去")
    }
    
    private func createNotification(_ id : Int, items: [ReminderItem], context: ModelContext) -> Bool {
        let item = getNotifiedItem(context, items: items)
        
        guard let firstNotificationDate = getFirstNotificationDate() else {
            print("通知の基準日時の作成に失敗しました。通知ID: \(id)")
            return false
        }
        
        guard let notificationDate = notificationTimeConverter(firstNotificationDate, id) else {
            print("通知の基準日時のコンバートに失敗しました。通知ID: \(id)")
            return false
        }
        
        let originID = UUID().uuidString
        
        let newItem = NotificationList(id: originID, content: item, notificationDate: notificationDate)
        context.insert(newItem)
        
//        recentNotificationList
//        scheduleNotification
        
        let content = UNMutableNotificationContent()
        content.title = "Re:Mind"
        content.body = id == lastNotificationId ? "\(item)\n通知の上限に達しました。設定より再度「保存」をタップしてください" : item
        content.sound = .default
         
        
        let component = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: notificationDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: component, repeats: false)
        let request = UNNotificationRequest(identifier: originID, content: content, trigger: trigger)
        
        scheduler.add(request) { error in
            if let error = error {
                print("スケジューリング失敗：\(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.notificationErrorMessage = "通知のスケジューリングに失敗しました。アプリを再起動してお試しください。"
                    self.showingNotificationErrorAlert = true
                }
            } else {
                let japanTime = DateConverter().japanTime(notificationDate)
                print("スケジューリング成功： id:\(id) 通知予定：\(japanTime)")
            }
        }
        return true
    }
    
    private func recentNotificationList (_ context: ModelContext) {
        // TODO: 直近のリスト取得→再考のため停止中(202510261844_42)
    }
    
    private func scheduleNotification () {
        
    }
    
    private func getNotifiedItem(_ context: ModelContext, items: [ReminderItem]) -> String {
                
        let notifiedItems = items.filter { $0.isNotificationEnable == true }
        
        let remindTexts: [String]
        if notifiedItems.count > 0 {
            remindTexts = notifiedItems.map { $0.text }
        } else {
            remindTexts = ["リストが空です"]
        }
        
        return remindTexts.randomElement() ?? "リストが空です"
    }
    
    private func getFirstNotificationDate() -> Date? {
        let now = Date()
        let baseTime = UserDefaults.standard.object(forKey: "baseTime") as? Date ?? Date()
        
        let calendar = Calendar(identifier: .gregorian)
        
        let year = calendar.component(.year, from: now)
        let month = calendar.component(.month, from: now)
        let day = calendar.component(.day, from: now)
        
        let hour = calendar.component(.hour, from: baseTime)
        let minute = calendar.component(.minute, from: baseTime)
        
        return calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute, second: 0))
    
    }
    
    private func notificationTimeConverter(_ setDate: Date, _ id: Int) -> Date? {
        let notificationDate = setDate.addingTimeInterval(TimeInterval(60 * 60 * selectedFrequency * id)) // 本番用
        
        let calendar = Calendar(identifier: .gregorian)
        
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: notificationDate)
        
        if isRandomTimeEnabled && selectedFrequency >= 24 {
            components.hour = Int.random(in: 0..<24)
            components.minute = Int.random(in: 0..<59)
        }
        
        return calendar.date(from: components)
           
    }

    
    // MARK: - 通知更新
    func updateNotification(context: ModelContext) {

        if !isNotificationEnabled { return }
        do {
            let existingNotifications = try context.fetch(
                FetchDescriptor<NotificationList>(
                    sortBy: [SortDescriptor(\.notificationDate, order: .forward)]
                )
            )

            let items = try context.fetch(
                FetchDescriptor<ReminderItem>(
                    sortBy: [SortDescriptor(\.createdAt, order: .forward)]
                )
            )
            let texts: [String] = {
                let enabled = items.filter { $0.isNotificationEnable }.map { $0.text }
                return enabled.isEmpty ? ["リストが空です"] : enabled
            }()

            for (index, notification) in existingNotifications.enumerated() {
                let baseBody = texts.randomElement() ?? "リストが空です"
                let isLast = index == existingNotifications.count - 1
                let newBody = isLast
                ? "\(baseBody)\n通知の上限に達しました。設定より再度「保存」をタップしてください"
                : baseBody
                notification.content = newBody

                if notification.notificationDate > Date() {
                    let content = UNMutableNotificationContent()
                    content.title = "Re:Mind"
                    content.body = newBody
                    content.sound = .default

                    let dc = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: notification.notificationDate)
                    let trigger = UNCalendarNotificationTrigger(dateMatching: dc, repeats: false)
                    let req = UNNotificationRequest(identifier: notification.id, content: content, trigger: trigger)
                    UNUserNotificationCenter.current().add(req) { error in
                        if let error = error {
                            print("通知更新時のスケジューリング失敗: \(error.localizedDescription)")
                            DispatchQueue.main.async {
                                self.notificationErrorMessage = "通知の更新に失敗しました。アプリを再起動してお試しください。"
                                self.showingNotificationErrorAlert = true
                            }
                        }
                    }
                }
            }

            try context.save()
        } catch {
            print("通知内容一括更新エラー: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.notificationErrorMessage = "通知の更新に失敗しました。アプリを再起動してお試しください。"
                self.showingNotificationErrorAlert = true
            }
        }
    }
    
    
    
}
