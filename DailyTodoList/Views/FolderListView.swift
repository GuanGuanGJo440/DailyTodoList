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

    var body: some View {
        NavigationStack {
            List(rootFolders, children: \.subFolders) { folder in
                HStack {
                    Image(systemName: "folder")
                        .foregroundColor(.blue)
                    Text(folder.name)
                    Spacer()
                    
                    // 快速新增子資料夾的按鈕
                    Button(action: { addSubFolder(to: folder) }) {
                        Image(systemName: "plus.circle")
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("已儲存清單")
            .toolbar {
                Button(action: addRootFolder) {
                    Label("新增主資料夾", systemImage: "folder.badge.plus")
                }
            }
        }
    }

    // 新增最上層資料夾
    private func addRootFolder() {
        let newFolder = Folder(name: "新資料夾")
        modelContext.insert(newFolder)
    }

    // 在指定資料夾下新增子資料夾
    private func addSubFolder(to parent: Folder) {
        let sub = Folder(name: "子資料夾")
        sub.parent = parent
        parent.subFolders?.append(sub)
    }
}
