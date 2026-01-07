//
//  TodoManager.swift
//  DailyTodoList
//
//  Created by 關關的m4 macbook pro on 2026/1/1.
//

import Foundation
import SwiftData
import SwiftUI

@Observable
class TodoManager {
    private var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        // 初始化時執行沒有 Tasks 的檢查
        setupDefaultFolders()
    }
    
    //MARK: - 檢查並執行每日 8 點的重置邏輯
    func checkAndResetDailyTasks() {
        let now = Date()
        let calendar = Calendar.current
        
        // 1. 取得「今天早上 8 點」的 Date 物件
        var components = calendar.dateComponents([.year, .month, .day], from: now)
        components.hour = 8
        components.minute = 0
        guard let eightAMToday = calendar.date(from: components) else { return }
        
        // 2. 從 UserDefaults 讀取「上次重置的時間」
        let lastResetDate = UserDefaults.standard.object(forKey: "LastResetDate") as? Date ?? Date.distantPast
        
        // 3. 判斷邏輯：
        // 如果「現在時間」已經超過「今天早上 8 點」
        // 且「上次重置時間」小於「今天早上 8 點」
        if now >= eightAMToday && lastResetDate < eightAMToday {
            executeReset()
            
            // 更新上次重置紀錄為現在
            UserDefaults.standard.set(now, forKey: "LastResetDate")
        }
    }
    
    //MARK: - 實際執行 SwiftData 資料更新
    private func executeReset() {
        // 抓取所有 isDaily 為 true 的事項
        let fetchDescriptor = FetchDescriptor<TodoItem>(
            predicate: #Predicate { $0.isDaily == true }
        )
        
        do {
            let allTasks = try modelContext.fetch(fetchDescriptor)
            
            for task in allTasks {
                // 1. 基本重置：如果是每日任務，勾選取消
                if task.isDaily {
                    task.isCompleted = false
                }
                
                // 2. 隨機模式處理：如果這個任務是「隨機抽籤」的父任務
                if task.taskType == "randomChild" && task.isDaily {
                    pickNewRandomSubtask(for: task)
                }
            }
            
            // 儲存變更
            try modelContext.save()
        } catch {
            print("重置失敗: \(error)")
        }
    }
    
    private func pickNewRandomSubtask(for parent: TodoItem) {
        guard let subs = parent.subTasks, !subs.isEmpty else { return }
        
        // 先把所有子任務的「今日目標」取消
        for sub in subs {
            sub.isTargetedForToday = false
            // 同時重置子任務的完成狀態，因為它是每日隨機的一部分
            sub.isCompleted = false
        }
        
        // 抽籤：這裡可以做「不重複」邏輯
        // 目前先簡單隨機抽一個
        if let randomChoice = subs.randomElement() {
            randomChoice.isTargetedForToday = true
            print("今日隨機目標：\(randomChoice.title)")
        }
    }
    
    //MARK: - 新增和刪除任務
    func addTask(
        title: String,
        isDaily: Bool,
        startDate: Date? = nil,
        endDate: Date? = nil,
        folder: Folder? = nil,
        parentTask: TodoItem? = nil,
        taskType: String = "normal"
    ) {
        let newTask = TodoItem(title: title, isDaily: isDaily, startDate: startDate, endDate: endDate)
        newTask.folder = folder
        newTask.taskType = taskType
        modelContext.insert(newTask)
        
        // 如果有分配資料夾，也雙向連結一下
        folder?.items?.append(newTask)
        parentTask?.subTasks?.append(newTask)
        
        try? modelContext.save()
    }

    func deleteTasks(_ tasks: [TodoItem], at offsets: IndexSet) {
        for index in offsets {
            let taskToDelete = tasks[index]
            modelContext.delete(taskToDelete)
        }
    }
    
    //MARK: - 連動父子任務邏輯
    func toggleTask(_ task: TodoItem) {
        task.isCompleted.toggle()
        
        // 向上連動：如果所有兄弟任務都完成了，父任務也完成
        if let parent = task.parentTask {
            let allSiblingsCompleted = parent.subTasks?.allSatisfy { $0.isCompleted } ?? false
            parent.isCompleted = allSiblingsCompleted
        }
        
        // 向下連動：如果這是一個父任務被勾選，所有子任務一起勾選
        if let subs = task.subTasks {
            for sub in subs {
                sub.isCompleted = task.isCompleted
            }
        }
    }
    
    //MARK: - 檢查是否已經有任何 Folder 資料
    private func setupDefaultFolders() {
        let fetchDescriptor = FetchDescriptor<Folder>()
        
        do {
            let existingFolders = try modelContext.fetch(fetchDescriptor)
            
            // 2. 如果資料夾是空的，才進行初始化
            if existingFolders.isEmpty {
                let defaultFolders = [
                    Folder(name: "每日任務", isSystem: true),
                    Folder(name: "定時任務", isSystem: true),
                    Folder(name: "專案任務", isSystem: true)
                ]
                
                for folder in defaultFolders {
                    modelContext.insert(folder)
                }
                
                try modelContext.save()
                print("已成功建立預設系統資料夾")
            }
        } catch {
            print("初始化預設資料夾失敗: \(error)")
        }
    }
}
