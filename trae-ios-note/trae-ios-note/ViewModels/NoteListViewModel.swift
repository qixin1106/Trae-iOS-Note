//
//  NoteListViewModel.swift
//  trae-ios-note
//
//  Created by XIN QI on 2025/11/6.
//

import Foundation
import SwiftData
import Combine

class NoteListViewModel: ObservableObject {
    @Published var notes: [Note] = []
    @Published var searchText: String = ""
    
    private var modelContext: ModelContext
    private var cancellables = Set<AnyCancellable>()
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchNotes()
        
        // 监听搜索文本变化
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.fetchNotes()
            }
            .store(in: &cancellables)
    }
    
    func fetchNotes() {
        var fetchDescriptor = FetchDescriptor<Note>()
        fetchDescriptor.sortBy = [SortDescriptor(\.lastModified, order: .reverse)]
        
        // 应用搜索过滤
        if !searchText.isEmpty {
            let searchPredicate = #Predicate<Note> { note in
                note.title.localizedStandardContains(searchText) || note.content.localizedStandardContains(searchText)
            }
            fetchDescriptor.predicate = searchPredicate
        }
        
        do {
            notes = try modelContext.fetch(fetchDescriptor)
        } catch {
            print("Failed to fetch notes: \(error)")
        }
    }
    
    func createNewNote() -> Note {
        let newNote = Note(title: "新笔记", content: "", lastModified: Date(), version: 1, isConflict: false)
        modelContext.insert(newNote)
        saveContext()
        fetchNotes()
        return newNote
    }
    
    func deleteNote(_ note: Note) {
        modelContext.delete(note)
        saveContext()
        fetchNotes()
    }
    
    func markAsConflict(_ note: Note) {
        note.isConflict = true
        saveContext()
        fetchNotes()
    }
    
    private func saveContext() {
        do {
            try modelContext.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
}