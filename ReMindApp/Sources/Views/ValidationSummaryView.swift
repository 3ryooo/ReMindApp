//
//  ValidationSummaryView.swift
//  ReMindApp
//

import SwiftUI


import SwiftUI

struct ValidationSummaryView: View {
    let errorMessages: [ReminderFormError]
    
    var body: some View {
        if !errorMessages.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(errorMessages) { error in
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                        Text(error.localizedDescription)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }
            .padding(8)
            .background(Color.red.opacity(0.1))
            .cornerRadius(8)
        }
    }
}

#Preview {
    ValidationSummaryView(errorMessages: [.empty, .overChar])
        .padding()
}
