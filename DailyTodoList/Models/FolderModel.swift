//
//  Folder.swift
//  DailyTodoList
//
//  Created by 關關的m4 macbook pro on 2025/12/31.
//

import Foundation
import SwiftData

@Model
final class Folder {
    var name: String
    var createdAt: Date
    
    // 指向父資料夾（如果是最上層則為 nil）
    var parent: Folder?
    
    // 包含的子資料夾，設定為連動刪除
    @Relationship(deleteRule: .cascade, inverse: \Folder.parent)
    var subFolders: [Folder]? = []
    
    // 該資料夾下的待辦事項
    @Relationship(deleteRule: .cascade, inverse: \TodoItem.folder)
    var items: [TodoItem]? = []

    init(name: String) {
        self.name = name
        self.createdAt = Date()
        self.subFolders = []
        self.items = []
    }
}
