//
//  NotificationErrorAlertModifier.swift
//  ReMindApp
//

import SwiftUI

struct NotificationErrorAlertModifier: ViewModifier {
    @Environment(NotificationStore.self) private var notificationStore
    private var bindableNotificationStore: Bindable<NotificationStore> { Bindable(notificationStore) }

    func body(content: Content) -> some View {
        content
            .alert("通知設定エラー", isPresented: bindableNotificationStore.showingNotificationErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(notificationStore.notificationErrorMessage)
            }
    }
}

extension View {
    func notificationErrorAlert() -> some View {
        modifier(NotificationErrorAlertModifier())
    }
}
