//
//  List.swift
//  DailyTodoList
//
//  Created by 關關的m4 macbook pro on 2025/12/31.
//

import SwiftUI
import SwiftData

struct FolderListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<Folder> { $0.parent == nil }, sort: \.createdAt)
    private var rootFolders: [Folder] // 只抓取最上層資料夾
    
    @State private var isShowingAddAlert = false
    @State private var newFolderName = ""
    
    // 用來記錄目前要新增到哪一個資料夾之下
    @State private var folderToAddTo: Folder? // 如果是 nil，代表新增在最外層；如果有值，代表新增子資料夾

    var body: some View {
        NavigationStack {
            List {
                ForEach(rootFolders) { folder in
                    // 使用 OutlineGroup 來支援無限階層展開
                    OutlineGroup(folder, children: \.subFolders) { element in
                        HStack {
                            Image(systemName: element.isSystem ? "archivebox.fill" : "folder")
                                .foregroundColor(element.isSystem ? .orange : .blue)
                            Text(element.name)
                            
                            if element.isSystem {
                                Text("系統")
                                    .font(.caption2)
                                    .padding(4)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(4)
                            }
                            Spacer()
                                                        
                            // 每一列右側的小按鈕
                            Button(action: {
                                folderToAddTo = element // 記錄父對象
                                isShowingAddAlert = true
                            }) {
                                Image(systemName: "plus.circle")
                                    .foregroundColor(.blue)
                            }
                            .buttonStyle(.plain) // 避免點擊整行觸發按鈕
                        }
                        .swipeActions(edge: .trailing) {
                            if !element.isSystem {
                                Button(role: .destructive) {
                                    deleteSpecificFolder(element)
                                } label: {
                                    Label("刪除", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .deleteDisabled(folder.isSystem)
                }
                .onDelete(perform: deleteFolder) // 在這裡加入刪除邏輯
            }
            .navigationTitle("已儲存清單")
            .toolbar {
                Button(action: {
                    folderToAddTo = nil // 清空，代表新增在最外層
                    isShowingAddAlert = true
                }) {
                    Label("新增主資料夾", systemImage: "folder.badge.plus")
                }
            }
            .alert(
                folderToAddTo == nil ? "新增主資料夾" : "新增子資料夾至「\(folderToAddTo?.name ?? "")」", isPresented: $isShowingAddAlert
            ) {
                TextField("資料夾名稱", text: $newFolderName)
                Button("取消", role: .cancel) {
                    newFolderName = ""
                    folderToAddTo = nil
                }
                Button("確定") {
                    if !newFolderName.isEmpty {
                        saveFolder(name: newFolderName)
                        newFolderName = "" // 清空輸入
                        folderToAddTo = nil
                    }
                }
            } message: {
                Text("請輸入新資料夾的名稱")
            }
        }
    }
    
    private func saveFolder(name: String) {
        let newFolder = Folder(name: name, isSystem: false)
        
        if let parent = folderToAddTo {
            // 如果有父資料夾，建立關聯
            newFolder.parent = parent
            if parent.subFolders == nil { parent.subFolders = [] }
            parent.subFolders?.append(newFolder)
        } else {
            // 否則就是最外層
            modelContext.insert(newFolder)
        }
    }
    
    // 刪除邏輯判斷
    private func deleteFolder(at offsets: IndexSet) {
        for index in offsets {
            let folder = rootFolders[index]
            // 關鍵判斷：如果是系統資料夾，則跳過不處理
            if !folder.isSystem {
                modelContext.delete(folder)
            } else {
                print("系統資料夾禁止刪除")
            }
        }
    }
    
    private func deleteSpecificFolder(_ folder: Folder) {
        // 雙重保險：檢查是否為系統資料夾
        if !folder.isSystem {
            modelContext.delete(folder)
            // SwiftData 會自動處理 parent/children 的關聯斷開
        }
    }
}
