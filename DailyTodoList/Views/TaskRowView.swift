//
//  TaskRowView.swift
//  DailyTodoList
//
//  Created by 關關的m4 macbook pro on 2026/1/3.
//

import SwiftUI

struct TaskRowView: View {
    @Bindable var item: TodoItem // 使用 @Bindable 讓勾選能直接反應
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(item.isCompleted ? .green : .gray)
                    .onTapGesture { item.isCompleted.toggle() }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.title)
                        .font(.headline)
                
                    if let parent = item.parentTask, parent.taskType == "randomChild" {
                        Text(parent.title)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(4)
                    }
                }
            }
            
            // 如果有子任務，縮排顯示
            if let subTasks = item.subTasks, !subTasks.isEmpty {
                // 1. 如果我是普通模式，顯示所有子任務
                // 2. 如果我是隨機模式，只顯示 isTargetedForToday 為 true 的子任務
                let visibleSubTasks = subTasks.filter { sub in
                    if item.taskType == "randomChild" {
                        return sub.isTargetedForToday
                    }
                    return true
                }
                ForEach(subTasks) { subTask in
                    TaskRowView(item: subTask) // 遞迴呼叫
                        .padding(.leading, 24)
                        .scaleEffect(0.95)
                }
            }
        }
    }
}
