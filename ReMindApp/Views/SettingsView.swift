//
//  SettingsView.swift
//  ReMindApp
//

import SwiftUI

struct SettingsView: View {
    
    @State private var isNotificationEnabled = true // テスト中のためtrue
    @State private var remindFrequency = ""
    @State private var remindTimes = ""
    
    @Environment(\.dismiss) private var dismiss
    
    
    var body: some View {
        NavigationView {
            Form {
                Toggle(isOn: $isNotificationEnabled) {
                    Text("通知ON")
                }
                if isNotificationEnabled {
                    
                    Picker("頻度を選択", selection: $remindFrequency) {
                        Text("1時間に1回")
                        Text("2時間に1回")
                        Text("3時間に1回")
                        Text("6時間に1回")
                        Text("9時間に1回")
                        Text("12時間に1回")
                        Text("1日に1回")
                        Text("2日に1回")
                        Text("3日に1回")
                        Text("5日に1回")
                        Text("1週間に1回")
                        Text("2週間に1回")
                        Text("1ヶ月に1回")
                        Text("3ヶ月に1回")
                        Text("半年に1回")
                        Text("1年に1回")
                    }
                    
                    
                    
//                    HStack {
//                        TextField("", text: $remindFrequency)
//                            .keyboardType(.numberPad)
//                        Text("日ごと")
//                        TextField("", text: $remindTimes)
//                            .keyboardType(.numberPad)
//                        Text("回")
//                    }
//                    Text("1日あたり\(Int(remindTimes) / Int(remindFrequency) )回")
//                    HStack {
//                        Text("\(remindFrequency)日ごと")
//                        Picker("リマインドの頻度", selection: $remindFrequency) {
//                            ForEach(1...101, id: \.self) { index in
//                                Text("\(index)").tag(index)
//                            }
//                        }
//                        .pickerStyle(.menu)
//                    }
//                    HStack {
//                        Text("\(remindFrequency)日あたり")
//                        Picker("リマインドの回数", selection: $remindFrequency) {
//                            Text("1日1回")
//                        }
//                        .pickerStyle(.wheel)
//                    }
                }
//                アラート追加？・保存ボタン等
                Button("追加") {
                    dismiss()
                }
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
//                        保存の処理追加
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
