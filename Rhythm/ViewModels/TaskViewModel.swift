//
//  TaskViewModel.swift
//  Rhythm
//
//  Created by Mason Foreman on 2/5/2025.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

// MARK: - Task Model
struct AppTask: Identifiable, Codable {
    let id: String
    var title: String
    var description: String
    var isCompleted: Bool
    var createdAt: Date
    var dueDate: Date?
    var userId: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case isCompleted
        case createdAt
        case dueDate
        case userId
    }
}

// MARK: - TaskViewModel
@MainActor
class TaskViewModel: ObservableObject {
    @Published var tasks: [AppTask] = []
    @Published var isLoading = false
    @Published var error: String?
    
    private let db = Firestore.firestore()
    
    // MARK: - Task Operations
    func fetchTasks() async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        isLoading = true
        error = nil
        
        do {
            let snapshot = try await db.collection("tasks")
                .whereField("userId", isEqualTo: userId)
                .getDocuments()
            
            tasks = snapshot.documents.compactMap { document in
                try? document.data(as: AppTask.self)
            }
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    nonisolated func addTask(title: String, description: String, dueDate: Date? = nil) async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let task = AppTask(
            id: UUID().uuidString,
            title: title,
            description: description,
            isCompleted: false,
            createdAt: Date(),
            dueDate: dueDate,
            userId: userId
        )
        
        do {
            try await db.collection("tasks").document(task.id).setData(from: task)
            await MainActor.run {
                tasks.append(task)
            }
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
            }
        }
    }
    
    nonisolated func updateTask(_ task: AppTask) async {
        do {
            try await db.collection("tasks").document(task.id).setData(from: task)
            await MainActor.run {
                if let index = tasks.firstIndex(where: { $0.id == task.id }) {
                    tasks[index] = task
                }
            }
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
            }
        }
    }
    
    nonisolated func deleteTask(_ task: AppTask) async {
        do {
            try await db.collection("tasks").document(task.id).delete()
            await MainActor.run {
                tasks.removeAll { $0.id == task.id }
            }
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
            }
        }
    }
}



