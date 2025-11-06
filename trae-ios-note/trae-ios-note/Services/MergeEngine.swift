//
//  MergeEngine.swift
//  trae-ios-note
//
//  Created by XIN QI on 2025/11/6.
//

import Foundation

class MergeEngine {
    static let shared = MergeEngine()
    
    private init() {}
    
    // 冲突检测
    func detectConflict(previousModified: Date, currentModified: Date) -> Bool {
        let timeInterval = currentModified.timeIntervalSince(previousModified)
        return timeInterval < 3.0 // 小于3秒视为冲突
    }
    
    // 自动合并（段落级）
    func mergeNotes(baseNote: Note, newNote: Note) -> Note? {
        guard detectConflict(previousModified: baseNote.lastModified, currentModified: newNote.lastModified) else {
            return newNote // 没有冲突，返回新笔记
        }
        
        // 尝试段落级合并
        let baseParagraphs = baseNote.content.components(separatedBy: .newlines)
        let newParagraphs = newNote.content.components(separatedBy: .newlines)
        
        // 合并逻辑：保留所有唯一段落
        var mergedParagraphs = Set<String>()
        mergedParagraphs.formUnion(baseParagraphs)
        mergedParagraphs.formUnion(newParagraphs)
        
        // 排序：先保留base的顺序，再添加new的新段落
        var finalParagraphs: [String] = []
        
        // 添加base中存在的段落
        for paragraph in baseParagraphs {
            if mergedParagraphs.contains(paragraph) {
                finalParagraphs.append(paragraph)
                mergedParagraphs.remove(paragraph)
            }
        }
        
        // 添加new中存在的新段落
        for paragraph in newParagraphs {
            if mergedParagraphs.contains(paragraph) {
                finalParagraphs.append(paragraph)
                mergedParagraphs.remove(paragraph)
            }
        }
        
        // 创建合并后的笔记
        var mergedNote = Note(title: newNote.title, content: finalParagraphs.joined(separator: "\n"), lastModified: Date(), version: max(baseNote.version, newNote.version) + 1, isConflict: false)
        mergedNote.id = baseNote.id // 保持相同的ID
        
        return mergedNote
    }
    
    // 手动解决冲突（选择保留哪个版本）
    func resolveConflict(originalNote: Note, selectedNote: Note) -> Note {
        var resolvedNote = selectedNote
        resolvedNote.id = originalNote.id
        resolvedNote.version = max(originalNote.version, selectedNote.version) + 1
        resolvedNote.lastModified = Date()
        resolvedNote.isConflict = false
        return resolvedNote
    }
}