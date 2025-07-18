//
//  ValidationSummaryView.swift
//  ReMindApp
//

import SwiftUI


// 現在未使用（複数のバリデーション発生時使用予定）
struct ValidationSummaryView: View {
    let errorMessages: [ReminderFormError]
    
    var body: some View {
        ForEach(errorMessages) { errorMessage in
            Text(errorMessage.errorDescription ?? "")
        }
    }
}

#Preview {
    ValidationSummaryView(errorMessages: [])
}
