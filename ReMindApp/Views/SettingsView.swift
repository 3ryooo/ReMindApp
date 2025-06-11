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
                    HStack {
                        TextField("", text: $remindFrequency)
                            .keyboardType(.numberPad)
                        Text("日ごと")
                        TextField("", text: $remindFrequency)
                            .keyboardType(.numberPad)
                        Text("回")
                    }
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
            }
        }
    }
}

#Preview {
    SettingsView()
}
