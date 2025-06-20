//
//  SettingsView.swift
//  ReMindApp
//

import SwiftUI
import UserNotifications

struct SettingsView: View {
    
    @State private var isNotificationEnabled = true // テスト中のためtrue
    @State private var selectedFrequency = UserDefaults.standard.integer(forKey: "frequencyKey")
    
    @State private var remindTimes = ""
    
    @State private var baseTime = Date.now
    
    @Environment(\.dismiss) private var dismiss
    
    
    var body: some View {
        NavigationView {
            Form {
//                TODO:　通知許可タイミングを設定&失敗したときの処理（操作方法をユーザさんに案内？）
                Button("通知認証") {
                    requestAuthorization()
                }
                Button("通知テスト") {
                    schaduleNotification()
                }
                Button("デバッグ用") {
                    
                }
//                ユーザーさんにとって基準時間はわかりにくい。（補足を用意する）
                DatePicker("基準時間", selection: $baseTime, displayedComponents: .hourAndMinute)
                Toggle(isOn: $isNotificationEnabled) {
                    Text("通知\(isNotificationEnabled ? "ON" : "OFF")")
                }
//                TODO:通知のベースの時間を追加（1日以下のときの説明や処理を検討）
                if isNotificationEnabled {
//                    TODO:tagを頻度に沿った値に変更する
//                    TODO:remindTimesも追加で設定する
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
                    
                }
//                アラート追加？・保存ボタン等
                Text("1日あたりの上限はxx回です")
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
                        UserDefaults.standard.set(selectedFrequency, forKey: "frequencyKey")
                        dismiss()
                    }
                }
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
            
        }
    }
    
    private func schaduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = "通知タイトル" // ランダムで作成？
        content.body = "通知ボディ" // テキストから抽出
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("スケジューリング失敗：\(error.localizedDescription)")
            } else {
                print("スケジューリング成功")
            }
        }
    }
    
    
}

#Preview {
    SettingsView()
}
