//
//  DailyTodoListApp.swift
//  DailyTodoList
//
//  Created by 關關的m4 macbook pro on 2025/12/31.
//

import SwiftUI
import SwiftData

@main
struct DailyTodoListApp: App {
    // 建立 ModelContainer
    let container: ModelContainer
    
    // 建立 Manager
    @State private var todoManager: TodoManager
    
    init() {
        do {
            container = try ModelContainer(for: Folder.self, TodoItem.self)
            // 初始化 Manager 並傳入 modelContext
            _todoManager = State(initialValue: TodoManager(modelContext: container.mainContext))
        } catch {
            fatalError("Failed to configure SwiftData Container")
        }
    }
    
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(todoManager) // 將 Manager 注入環境，方便 View 使用
        }
        // 同時註冊 Folder 和 TodoItem
        .modelContainer(for: [Folder.self, TodoItem.self])
        .onChange(of: scenePhase) { oldPhase, newPhase in
            // 當 App 進入活躍狀態 (active) 時執行檢查
            if newPhase == .active {
                todoManager.checkAndResetDailyTasks()
            }
        }
    }
}
