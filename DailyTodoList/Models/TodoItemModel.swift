//
//  TodoItemModel.swift
//  DailyTodoList
//
//  Created by 關關的m4 macbook pro on 2026/1/1.
//
import Foundation
import SwiftData

@Model
final class TodoItem {
    var title: String
    var isCompleted: Bool = false
    var createdAt: Date = Date()
    
    // 1. 每日重置標記
    var isDaily: Bool = false
    
    // 2. 每週/每年重複邏輯 (可用 Enum 或 String 簡化)
    var repeatPattern: String? // "Monday", "9/23", nil
    
    // 3. 有時效性的任務
    var startDate: Date?
    var endDate: Date?
    
    // 指向父任務
    var parentTask: TodoItem?
    
    // 包含的子任務
    @Relationship(deleteRule: .cascade, inverse: \TodoItem.parentTask)
    var subTasks: [TodoItem]? = []
    
    // 標記是否為今日隨機選中的目標
    var isTargetedForToday: Bool = false
    var taskType: String = "normal"      // "normal" 或 "randomChild"
    
    // 關聯：所屬資料夾
    var folder: Folder?

    init(title: String, isDaily: Bool = false, startDate: Date? = nil, endDate: Date? = nil) {
        self.title = title
        self.isDaily = isDaily
        self.startDate = startDate
        self.endDate = endDate
        self.subTasks = []
    }
}
