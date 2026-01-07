//
//  AddTaskView.swift
//  DailyTodoList
//
//  Created by 關關的m4 macbook pro on 2026/1/2.
//

import SwiftUI
import SwiftData

struct AddTaskSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(TodoManager.self) private var todoManager
    
    // 取得所有根資料夾，用來顯示樹狀結構
    @Query(filter: #Predicate<Folder> { $0.parent == nil }) private var rootFolders: [Folder]
    
    // 取得所有「沒有父任務」的事項，作為父任務選擇的起點
    @Query(filter: #Predicate<TodoItem> { $0.parentTask == nil })
    private var topLevelTasks: [TodoItem]
    
    // 紀錄選中的父任務
    @State private var selectedParentTask: TodoItem?
    
    // State 變數控制表單輸入
    @State private var title: String = ""
    @State private var isDaily: Bool = false
    
    // 用來控制任務執行模式
    @State private var taskType: String = "normal" // "normal" 或 "randomChild"
    
    @State private var hasDuration: Bool = false
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date().addingTimeInterval(86400) // 預設明天
    
    @State private var selectedFolder: Folder?

    var body: some View {
        NavigationStack {
            Form {
                Section("基本資訊") {
                    TextField("想要做什麼？", text: $title)
                    Toggle("每日重複 (08:00 重置)", isOn: $isDaily)
                }
                
                // 普通模式 or 隨機抽取子任務模式
                Section("執行模式") {
                    Picker("模式", selection: $taskType) {
                        Text("普通模式").tag("normal")
                        Text("隨機抽取子任務").tag("randomChild")
                    }
                    .pickerStyle(.segmented)
                    
                    if taskType == "randomChild" {
                        Text("系統每日將從其子任務中隨機挑選一項顯示。")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("時效性 (專案)") {
                    Toggle("設定起迄日期", isOn: $hasDuration)
                    if hasDuration {
                        DatePicker("開始日期", selection: $startDate, displayedComponents: .date)
                        DatePicker("結束日期", selection: $endDate, displayedComponents: .date)
                    }
                }
                
                Section("階層設定") {
                    Menu {
                        Button("設為主任務 (無父項目)") { selectedParentTask = nil }
                        Divider()
                        // 呼叫遞迴任務選單
                        TaskMenuRecursiveView(tasks: topLevelTasks, selection: $selectedParentTask)
                    } label: {
                        HStack {
                            Text("所屬父任務")
                            Spacer()
                            Text(selectedParentTask?.title ?? "無")
                                .foregroundColor(.blue)
                                .lineLimit(1)
                        }
                    }
                }
                
                Section("分類至資料夾") {
                    // 使用 Menu 配合樹狀結構顯示會比 Picker 更清楚
                    Menu {
                        Button("無資料夾 (收件匣)") { selectedFolder = nil }
                        
                        // 遞迴顯示所有資料夾
                        FolderMenuRecursiveView(folders: rootFolders, selection: $selectedFolder)
                        
                    } label: {
                        HStack {
                            Text("目標資料夾")
                            Spacer()
                            Text(selectedFolder?.name ?? "未分類")
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .navigationTitle("新增事項")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("儲存") {
                        saveTask()
                    }
                    .disabled(title.isEmpty) // 沒標題不能存
                }
            }
            .onChange(of: selectedParentTask) { oldTask, newTask in
                if let parentFolder = newTask?.folder {
                    self.selectedFolder = parentFolder
                }
            }
        }
    }

    private func saveTask() {
        // 呼叫 manager 儲存
        todoManager.addTask(
            title: title,
            isDaily: isDaily,
            startDate: hasDuration ? startDate : nil,
            endDate: hasDuration ? endDate : nil,
            folder: selectedFolder,
            parentTask: selectedParentTask,
            taskType: taskType
        )
        dismiss()
    }
}

struct FolderMenuRecursiveView: View {
    let folders: [Folder]
    @Binding var selection: Folder?

    var body: some View {
        ForEach(folders) { folder in
            if let subFolders = folder.subFolders, !subFolders.isEmpty {
                Menu(folder.name) {
                    Button("選擇此資料夾") { selection = folder }
                    Divider()
                    FolderMenuRecursiveView(folders: subFolders, selection: $selection)
                }
            } else {
                Button(folder.name) { selection = folder }
            }
        }
    }
}

// 任務遞迴選單
struct TaskMenuRecursiveView: View {
    let tasks: [TodoItem]
    @Binding var selection: TodoItem?

    var body: some View {
        ForEach(tasks) { task in
            // 如果有子任務，顯示為子選單
            if let subs = task.subTasks, !subs.isEmpty {
                Menu(task.title) {
                    Button("選擇此任務: \(task.title)") { selection = task }
                    Divider()
                    TaskMenuRecursiveView(tasks: subs, selection: $selection)
                }
            } else {
                // 沒有子任務，直接顯示按鈕
                Button(task.title) { selection = task }
            }
        }
    }
}
