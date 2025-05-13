//
//  Task.swift
//  Rhythm
//
//  Created by Chris Joju on 2/5/2025.
//


import Foundation

struct TaskModel: Identifiable, Codable, Hashable {
    let id: UUID
    let title: String
    let dueDate: Date
    let estimatedMinutes: Int
    var isCompleted: Bool
    
    init(title: String, dueDate: Date, estimatedMinutes: Int, isCompleted: Bool = false) {
        self.id = UUID()
        self.title = title
        self.dueDate = dueDate
        self.estimatedMinutes = estimatedMinutes
        self.isCompleted = isCompleted
    }
}
