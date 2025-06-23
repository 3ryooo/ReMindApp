//
//  SettingsView.swift
//  ReMindApp
//

import SwiftUI
import SwiftData
import UserNotifications

struct SettingsView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [ReminderItem]
    
    @State private var isNotificationEnabled = UserDefaults.standard.bool(forKey: "isNotificationEnabled")
    @State private var selectedFrequency = UserDefaults.standard.integer(forKey: "frequencyKey")
    @State private var baseTime = UserDefaults.standard.object(forKey: "baseTime") as? Date ?? Date() // TODO:二重になっているので修正する
    
    @State private var remindTimes = ""
    @State private var showingAuthorizationAlert = false
    
    //    テスト中のため数を少なめに設定
    let lastNotificationId = 5
    
    private var notifiedItems: [ReminderItem] {
        var filterd = items
        
        filterd = filterd.filter { $0.isNotificationEnable == true }
        
        return filterd
    }
    
    
    
    @Environment(\.dismiss) private var dismiss
    
    
    var body: some View {
        NavigationView {
            Form {
//                TODO:　通知許可タイミングを設定&失敗したときの処理（操作方法をユーザさんに案内？）
                Toggle(isOn: $isNotificationEnabled) {
                    Text("通知\(isNotificationEnabled ? "ON" : "OFF")")
                }
                .onChange(of: isNotificationEnabled) {
                    requestAuthorization()
                }
//                TODO:通知のベースの時間を追加（1日以下のときの説明や処理を検討）
                if isNotificationEnabled {
//                    TODO:tagを頻度に沿った値に変更する
//                    TODO:remindTimesも追加で設定する
//                    TODO:短い時間は夜でも通知が来てしまう→範囲設定 or ユーザーさんの集中モードで対応？
                    Picker("通知の頻度", selection: $selectedFrequency) {
                        Text("1時間に1回").tag(1)
                        Text("2時間に1回").tag(2)
                        Text("3時間に1回").tag(3)
                        Text("6時間に1回").tag(6)
                        Text("9時間に1回").tag(9)
                        Text("12時間に1回").tag(12)
                        Text("1日に1回").tag(24)
                        Text("2日に1回").tag(48)
                        Text("3日に1回").tag(72)
                        Text("5日に1回").tag(120)
                        Text("1週間に1回").tag(168)
                        Text("2週間に1回").tag(336)
                        Text("1ヶ月に1回").tag(720)
                        Text("3ヶ月に1回").tag(2160)
                        Text("半年に1回").tag(4320)
                        Text("1年に1回").tag(8640)
                    }
                    //                ユーザーさんにとって基準時間はわかりにくい。（補足を用意する）
                    DatePicker("基準時間", selection: $baseTime, displayedComponents: .hourAndMinute)
                }

//                アラート追加？・保存ボタン等
//                TODO:レビューや連絡のボタン
            }
            .navigationTitle("設定")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("保存") {
                        UserDefaults.standard.set(isNotificationEnabled, forKey: "isNotificationEnabled")
                        UserDefaults.standard.set(selectedFrequency, forKey: "frequencyKey")
                        UserDefaults.standard.set(baseTime, forKey: "baseTime")
                        setNotificationList()
                        dismiss()
                    }
                }
            }
            .alert("通知がオフになっています", isPresented: $showingAuthorizationAlert) {
                Button("キャンセル", role: .cancel) { }
                Button("設定を開く") {
                    openAppSettings()
                }
            } message: {
                //                TODO:もう少し丁寧な説明をしたい
                Text("リマインド機能をオンにするには、設定アプリから通知をオンにしてください")
            }
        }
    }
    
    private func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("許可")
            } else if let error = error {
                print("失敗：\(error.localizedDescription)")
            }
            
            if !success {
                DispatchQueue.main.async {
                    showingAuthorizationAlert = true
                }
            }
            
        }
        
    }
    
    private func openAppSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    func setNotificationList() {
        
        //        トリガーは保存時のみ？→長期的なリマインドが毎回消えてしまう
        let lcNotification = UNUserNotificationCenter.current()
        lcNotification.removeAllPendingNotificationRequests()
        
        for i in 1...lastNotificationId {
            setNotification(i)
        }
        
        
    }
    
    //    TODO:トリガーを変更する
    private func setNotification(_ id : Int) {
        
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

#Preview {
    SettingsView()
}
