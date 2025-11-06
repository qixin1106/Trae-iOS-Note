//
//  VersionManager.swift
//  trae-ios-note
//
//  Created by XIN QI on 2025/11/6.
//

import Foundation

class VersionManager {
    static let shared = VersionManager()
    
    private let fileManager = FileManager.default
    private let historyDirectoryName = "NotesHistory"
    
    private init() {}
    
    // 获取笔记历史目录
    private func getHistoryDirectory(for noteId: UUID) throws -> URL {
        let documentsDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let historyDirectory = documentsDirectory.appendingPathComponent(historyDirectoryName)
        let noteHistoryDirectory = historyDirectory.appendingPathComponent(noteId.uuidString)
        
        // 创建目录（如果不存在）
        try fileManager.createDirectory(at: noteHistoryDirectory, withIntermediateDirectories: true, attributes: nil)
        
        return noteHistoryDirectory
    }
    
    // 保存快照
    func saveSnapshot(for note: Note) throws {
        let snapshot = NoteSnapshot(note: note)
        let noteHistoryDirectory = try getHistoryDirectory(for: note.id)
        
        // 创建快照文件路径
        let timestamp = snapshot.snapshotDate.timeIntervalSince1970
        let snapshotFileName = "\(timestamp).json"
        let snapshotFileURL = noteHistoryDirectory.appendingPathComponent(snapshotFileName)
        
        // 序列化并保存
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(snapshot)
        try data.write(to: snapshotFileURL)
    }
    
    // 获取所有快照
    func getSnapshots(for noteId: UUID) throws -> [NoteSnapshot] {
        let noteHistoryDirectory = try getHistoryDirectory(for: noteId)
        
        // 获取所有JSON文件
        let files = try fileManager.contentsOfDirectory(at: noteHistoryDirectory, includingPropertiesForKeys: nil)
        let jsonFiles = files.filter { $0.pathExtension == "json" }
        
        // 解析并排序快照
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        var snapshots: [NoteSnapshot] = []
        for fileURL in jsonFiles {
            let data = try Data(contentsOf: fileURL)
            let snapshot = try decoder.decode(NoteSnapshot.self, from: data)
            snapshots.append(snapshot)
        }
        
        // 按时间倒序排列
        return snapshots.sorted { $0.snapshotDate > $1.snapshotDate }
    }
    
    // 删除所有快照
    func deleteSnapshots(for noteId: UUID) throws {
        let noteHistoryDirectory = try getHistoryDirectory(for: noteId)
        try fileManager.removeItem(at: noteHistoryDirectory)
    }
    
    // 从快照恢复笔记
    func restoreNote(from snapshot: NoteSnapshot, modelContext: ModelContext) throws -> Note? {
        // 查找现有笔记
        let fetchDescriptor = FetchDescriptor<Note>(predicate: #Predicate { $0.id == snapshot.id })
        guard var note = try modelContext.fetch(fetchDescriptor).first else {
            return nil
        }
        
        // 更新笔记内容
        note.title = snapshot.title
        note.content = snapshot.content
        note.lastModified = Date()
        note.version = snapshot.version + 1
        note.isConflict = false
        
        // 保存恢复后的快照
        try saveSnapshot(for: note)
        
        return note
    }
}