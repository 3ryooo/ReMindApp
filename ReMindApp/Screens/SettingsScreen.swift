//
//  SettingsView.swift
//  ReMindApp
//

import SwiftUI
import SwiftData
import StoreKit
import UserNotifications

struct SettingsScreen: View {
    
    @Environment(NotificationStore.self) private var notificationStore
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [ReminderItem]
    
    private var bindableNotificationStore: Bindable<NotificationStore> {
        Bindable(notificationStore)
    }
    
    @State private var randomRemind = false
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.requestReview) private var requestReview
    
    
    var body: some View {
        NavigationView {
            Form {
                //                TODO:　通知許可タイミングを設定&失敗したときの処理（操作方法をユーザさんに案内？）
                Toggle(isOn: bindableNotificationStore.isNotificationEnabled) {
                    Text("通知\(notificationStore.isNotificationEnabled ? "ON" : "OFF")")
                }
                .onChange(of: notificationStore.isNotificationEnabled) {
                    notificationStore.requestAuthorization()
                }
                //                TODO:通知のベースの時間を追加（1日以下のときの説明や処理を検討）
                if notificationStore.isNotificationEnabled {
                    //                    TODO:tagを頻度に沿った値に変更する
                    //                    TODO:randomRemind機能の実装
                    //                    TODO:短い時間は夜でも通知が来てしまう→範囲設定 or ユーザーさんの集中モードで対応？
                    Picker("通知の頻度", selection: bindableNotificationStore.selectedFrequency) {
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
//                    TODO:時間ランダム時のbasetimeの処理
                    Toggle(isOn: bindableNotificationStore.isRandomTimeEnabled) {
                        Text("時間ランダム")
                    }
                    //                ユーザーさんにとって基準時間はわかりにくい。（補足を用意する）
                    DatePicker("基準時間", selection: bindableNotificationStore.baseTime, displayedComponents: .hourAndMinute)
                }
                
                Button("インポート") {
//                    TODO:エクスポート機能とマージ？
                }
                
                Button("エクスポート") {
                    
                }
                
                Button("評価する") {
                    requestReview()
                }
                Button("お問い合わせ") {
                    //                    TODO:作成予定
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
                        
                        if notificationStore.notificationSaveTimes == 10 {
                            requestReview()
                        }
                        
                        notificationStore.saveSettings()
                        if notificationStore.isNotificationEnabled {
                            notificationStore.setNotificationList(for: items)
                        } else {
                            notificationStore.removeAllNotification()
                        }
                        
                        dismiss()
                    }
                }
            }
            .alert("通知がオフになっています", isPresented: bindableNotificationStore.showingAuthorizationAlert) {
                Button("キャンセル", role: .cancel) { }
                Button("設定を開く") {
                    NotificationManager().openAppSettings()
                }
            } message: {
                //                TODO:もう少し丁寧な説明をしたい
                Text("リマインド機能をオンにするには、設定アプリから通知をオンにしてください")
            }
        }
    }
    
    
}


#Preview {
    SettingsScreen()
        .environment(NotificationStore())
}
