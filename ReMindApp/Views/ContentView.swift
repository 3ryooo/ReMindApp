//
//  ContentView.swift
//  ReMindApp
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [ReminderItem]
    
    @State private var showingAddReminderSheet = false
    
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(items) { item in
                    Text(item.text)
                }
            }
            .navigationTitle("リマインドリスト")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddReminderSheet = true
                    } label: {
                        Label("リマインド追加", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddReminderSheet) {
                AddReminderView()
            }
        }
    }
}

#Preview {
    ContentView()
}
