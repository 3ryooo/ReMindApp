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
                    NavigationLink(destination: EditReminderView(reminderItem: item)) {
                        Text(item.text)
                    }
                }
                .onDelete(perform: deleteItems)
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
            .overlay {
                if items.isEmpty {
                    ContentUnavailableView {
                        Label("リマインダーなし", systemImage: "tray.fill")
                    } description: {
                        Text("右上からタスクを追加してください")
                    }
                }
            }
        }
    }
    
    func deleteItems(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(items[index])
        }
    }
}

#Preview {
    ContentView()
}
