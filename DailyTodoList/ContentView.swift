//
//  ContentView.swift
//  DailyTodoList
//
//  Created by 關關的m4 macbook pro on 2025/12/31.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    
    @Environment(TodoManager.self) private var todoManager
    
    // 查詢「今天要做的事」：未完成，或者是每日任務
    @Query(filter: #Predicate<TodoItem> { $0.isCompleted == false || $0.isDaily == true })
    private var todayTasks: [TodoItem]
    
    @State private var isShowingFolderList = false

    var body: some View {
        NavigationStack {
            List {
                Section("今天要做的事") {
                    ForEach(todayTasks) { item in
                        TaskRowView(item: item)
                    }
                    .onDelete { offsets in
                            // 呼叫 Manager 的刪除功能
                            todoManager.deleteTasks(todayTasks, at: offsets)
                        }
                    }
                }
                Section {
                    Button(action: { isShowingFolderList = true }) {
                        Label("查看已儲存清單", systemImage: "folder.fill")
                    }
                }
            }
            .navigationTitle("Daily To-do")
            .sheet(isPresented: $isShowingFolderList) {
                // 這裡放你之前寫的 FolderListView
                FolderListView()
            }
            .toolbar {
                Button(action: {
                    // 呼叫 Manager 的新增功能
                    todoManager.addTask(title: "新任務 \(Date().formatted(.dateTime))", isDaily: true)
                }) {
                    Label("新增事項", systemImage: "plus")
            }
            .onAppear {
                todoManager.checkAndResetDailyTasks()
            }
        }
    }
}

