//
//  ValidationSummaryView.swift
//  ReMindApp
//

import SwiftUI

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
