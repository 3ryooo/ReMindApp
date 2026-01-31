//
//  SettingsView.swift
//  ReMindApp
//

import MessageUI
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
    @AppStorage("appNotificationEnabled") private var appIsNotificationEnabled: Bool = false
    @AppStorage("isRandomTimeEnabled") private var appIsRandomTimeEnabled: Bool = false
    @AppStorage("frequencyKey") private var appSelectedFrequency: Int = 24
    @AppStorage("countForReviewRequest") private var appCountForReviewRequest: Int = 0
    @State private var randomRemind = false
    @State private var showingBaseTimeHelp = false
    @State private var showingRandomTimeHelp = false
    @State private var isShowingMailView = false
    @State private var tempIsNotificationEnabled: Bool = false
    @State private var tempIsRandomTimeEnabled: Bool = false
    @State private var tempSelectedFrequency: Int = 24
    @State private var tempCountForReviewRequest: Int = 0
    @State private var tempBaseTime = UserDefaults.standard.object(forKey: "baseTime") as? Date ?? Date()
    @State private var showingSaveAlert = false
    
    private var isChanged: Bool {
        return !(
            notificationStore.appNotificationEnabled == tempIsNotificationEnabled &&
            notificationStore.isRandomTimeEnabled == tempIsRandomTimeEnabled &&
            notificationStore.selectedFrequency == tempSelectedFrequency &&
            notificationStore.baseTime == tempBaseTime
        )
    }
    
    private var bindableNotificationStore: Bindable<NotificationStore> {
        Bindable(notificationStore)
    }
    
    
    // MARK: - SettingView
    var body: some View {
        #if DEBUG
        Button("UserDefaults設定確認"){
            test()
        }
        #endif
        Form {
                Section() {
                    Toggle(isOn: $tempIsNotificationEnabled) {
                        Text("通知\(tempIsNotificationEnabled ? "ON" : "OFF")")
                    }
                    .onChange(of: tempIsNotificationEnabled) {
                        if tempIsNotificationEnabled {
                            notificationStore.requestAuthorization()
                        }
                    }
                    // TODO: （転記済）短い時間は夜でも通知が来てしまう→範囲設定 or ユーザーさんの集中モードで対応？(202510190715_51)
                    frequencyPicker
                    HStack {
                        DatePicker("基準時間", selection: $tempBaseTime, displayedComponents: .hourAndMinute)
                        Button(action: {
                            showingBaseTimeHelp = true
                        }) {
                            Image(systemName: "questionmark.circle")
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    HStack {
                        Toggle(isOn: $tempIsRandomTimeEnabled) {
                            Text("時間ランダム")
                        }
                        .disabled(tempSelectedFrequency < 24)
                        
                        Button(action: {
                            showingRandomTimeHelp = true
                        }) {
                            Image(systemName: "questionmark.circle")
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                Section("アプリについて"){
                    Button("評価する") {
                        requestReview()
                    }
                    Button("お問い合わせ") {
                        if MFMailComposeViewController.canSendMail() {
                            isShowingMailView = true
                        } else {
                            let email = Bundle.main.object(forInfoDictionaryKey: "SupportEmail") as? String ?? ""
                            let subject = "問い合わせ"
                            let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                            
                            let urlString = "mailto:\(email)?subject=\(encodedSubject)"
                            
                            if let emailURL = URL(string: urlString) {
                                DispatchQueue.main.async {
                                    UIApplication.shared.open(emailURL) { success in
                                        if !success {
                                            print("メールアプリを開けませんでした")
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
        }
        .navigationTitle("設定")
        .navigationBarBackButtonHidden(true)
        .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        if isChanged == true {
                            showingSaveAlert = true
                        } else {
                            dismiss()
                        }
                    }) {
                        Image(systemName: "xmark")
                            .foregroundStyle(.primary)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("保存") {
                        
                        if notificationStore.countForReviewRequest == 10 {
                            requestReview()
                        }
                        
                        notificationStore.appNotificationEnabled = tempIsNotificationEnabled
                        notificationStore.isRandomTimeEnabled = tempIsRandomTimeEnabled
                        notificationStore.selectedFrequency = tempSelectedFrequency
                        notificationStore.baseTime = tempBaseTime
                        
                        notificationStore.saveSettings()
                        if notificationStore.appNotificationEnabled {
                            notificationStore.setNotificationList(for: items)
                        } else {
                            notificationStore.removeAllNotification()
                        }
                        
                        dismiss()
                    }
                }
            }
            .onAppear {
                tempIsNotificationEnabled = appIsNotificationEnabled
                tempIsRandomTimeEnabled = appIsRandomTimeEnabled
                tempSelectedFrequency = appSelectedFrequency
                tempCountForReviewRequest = appCountForReviewRequest
            }
            .alert("通知がオフになっています", isPresented: bindableNotificationStore.showingAuthorizationAlert) {
                Button("キャンセル", role: .cancel) { }
                Button("設定を開く") {
                    NotificationManager().openAppSettings()
                }
            } message: {
                Text("リマインド機能をオンにするには、設定アプリから「通知を許可」をオンにしてください")
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
            .sheet(isPresented: $isShowingMailView) {
                MailScreen(isShowing: $isShowingMailView)
            }
            .alert("保存されていない変更を破棄しますか？", isPresented: $showingSaveAlert) {
                Button("キャンセル", role: .cancel) { }
                Button("破棄", role: .destructive) {
                    dismiss()
                }
            }
        
    }
    
    var frequencyPicker: some View {
        Picker("通知の頻度", selection: $tempSelectedFrequency) {
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
    
    func test(){
        print("\(notificationStore.appNotificationEnabled), \(tempIsNotificationEnabled)")
        print("\(notificationStore.isRandomTimeEnabled), \(tempIsRandomTimeEnabled)")
        print("\(notificationStore.selectedFrequency), \(tempSelectedFrequency)")
        print("\(notificationStore.baseTime), \(tempBaseTime)")
        
    }
}


// MARK: - プレビュー
#Preview {
    SettingsScreen()
        .modelContainer(for: [ReminderItem.self])
        .environment(NotificationStore())
}
