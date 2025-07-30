//
//  SettingsView.swift
//  ReMindApp
//

import SwiftUI
import SwiftData
import StoreKit
import UserNotifications

struct SettingsScreen: View {
    
    // MARK: - プロパティ
    @Environment(NotificationStore.self) private var notificationStore
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.requestReview) private var requestReview
    @Query private var items: [ReminderItem]
    @State private var randomRemind = false
    @State private var showingBaseTimeHelp = false
    @State private var showingRandomTimeHelp = false
    
    private var bindableNotificationStore: Bindable<NotificationStore> {
        Bindable(notificationStore)
    }
    
    
    // MARK: - SettingView
    var body: some View {
        NavigationView {
            Form {
                Section() {
                    Toggle(isOn: bindableNotificationStore.isNotificationEnabled) {
                        Text("通知\(notificationStore.isNotificationEnabled ? "ON" : "OFF")")
                    }
                    .onChange(of: notificationStore.isNotificationEnabled) {
                        notificationStore.requestAuthorization()
                    }
                    // TODO: 短い時間は夜でも通知が来てしまう→範囲設定 or ユーザーさんの集中モードで対応？
                    frequencyPicker
                    HStack {
                        DatePicker("基準時間", selection: bindableNotificationStore.baseTime, displayedComponents: .hourAndMinute)
                        Button(action: {
                            showingBaseTimeHelp = true
                        }) {
                            Image(systemName: "questionmark.circle")
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    HStack {
                        Toggle(isOn: bindableNotificationStore.isRandomTimeEnabled) {
                            Text("時間ランダム")
                        }
                        .disabled(notificationStore.selectedFrequency < 24)
                        
                        Button(action: {
                            showingRandomTimeHelp = true
                        }) {
                            Image(systemName: "questionmark.circle")
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                Section("データ管理"){
                    Button("インポート") {
                        // TODO: エクスポート機能とマージ？
                    }
                    
                    Button("エクスポート") {
                        
                    }
                }
                Section("アプリについて"){
                    Button("評価する") {
                        requestReview()
                    }
                    Button("お問い合わせ") {
                        //  TODO: 作成予定
                    }
                }
            }
            .navigationTitle("設定")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("保存") {
                        
                        if notificationStore.countForReviewRequest == 10 {
                            requestReview()
                        }
                        
                        notificationStore.saveSettings()
                        if notificationStore.isNotificationEnabled {
                            notificationStore.setNotificationList(for: items, context: modelContext)
                        } else {
                            notificationStore.removeAllNotification(modelContext)
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
                // TODO: もう少し丁寧な説明をしたい
                Text("リマインド機能をオンにするには、設定アプリから通知をオンにしてください")
            }
            .alert("通知設定エラー", isPresented: bindableNotificationStore.showingNotificationErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(notificationStore.notificationErrorMessage)
            }
            .alert("基準時間とは？", isPresented: $showingBaseTimeHelp) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("基準時間は通知の開始時刻です。\n\n例：基準時間を9:00、頻度を3時間に設定した場合、9:00、12:00、15:00...の順で通知が送信されます。")
            }
            .alert("時間ランダムとは？", isPresented: $showingRandomTimeHelp) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("ONにすると、通知時刻が毎回ランダムな時間（0:00〜23:59）に変更されます。\n\n時間ランダムは1日以上の頻度でのみ有効な機能です。\n\n1日未満の頻度では基準時間から正確な間隔で通知されます。")
            }
        }
        
    }
    
    var frequencyPicker: some View {
        Picker("通知の頻度", selection: bindableNotificationStore.selectedFrequency) {
            Text("1時間に1回").tag(1)
            Text("2時間に1回").tag(2)
            Text("3時間に1回").tag(3)
            Text("6時間に1回").tag(6)
            Text("9時間に1回").tag(9)
            Text("12時間に1回").tag(12)
            Text("1日に1回").tag(24)
            Text("2日に1回").tag(24 * 2)
            Text("3日に1回").tag(24 * 3)
            Text("5日に1回").tag(24 * 5)
            Text("1週間に1回").tag(24 * 7)
            Text("2週間に1回").tag(24 * 14)
            Text("1ヶ月に1回").tag(24 * 30) // FIXME: 日付が固定されない（月ごとに日数が異なるため）
            Text("3ヶ月に1回").tag(24 * 30 * 3)
            Text("半年に1回").tag(24 * 30 * 6)
            Text("1年に1回").tag(24 * 30 * 12)
        }
    }
    
}


// MARK: - プレビュー
#Preview {
    SettingsScreen()
        .environment(NotificationStore())
}
