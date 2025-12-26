//
//  ReminderFormFields.swift
//  ReMindApp
//
//  共通の入力フィールド（テキスト／通知トグル）を提供するビュー
//

import SwiftUI

struct ReminderFormView: View {
    // MARK: - Bindings
    @Binding var text: String
    @Binding var itemNotificationEnabled: Bool

    // MARK: - Body
    var body: some View {
        Group {
            TextField("リマインドテキスト", text: $text, axis: .vertical)
            Toggle(isOn: $itemNotificationEnabled) {
                Text("リマインド対象")
            }
        }
    }
}
