//
//  TasksView.swift
//  Rhythm
//
//  Created by Chris Joju on 13/5/2025.
//

import SwiftUI

struct TasksView: View {
    let title: String
    let tasks: [TaskModel]
    let showTimerButton: Bool

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.largeTitle)
                .bold()
                .padding()

            if tasks.isEmpty {
                Text("No tasks to display.")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                List(tasks) { task in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(task.isCompleted ? .green : .gray)
                            Text(task.title)
                                .fontWeight(.medium)
                        }

                        Text("Due: \(task.dueDate.formatted(date: .abbreviated, time: .shortened))")
                            .font(.caption)
                            .foregroundColor(.gray)

                        Text("Est: \(task.estimatedMinutes) min")
                            .font(.caption2)
                            .foregroundColor(.secondary)

                        if showTimerButton {
                            NavigationLink(destination: PomodoroView()) {
                                Text("Start Timer")
                                    .font(.caption)
                                    .padding(6)
                                    .background(Color.blue.opacity(0.2))
                                    .cornerRadius(8)
                            }
                            .padding(.top, 4)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle(title)
    }
}

#Preview {
    TasksView(
        title: "Sample Tasks",
        tasks: [
            TaskModel(title: "Read notes", dueDate: Date(), estimatedMinutes: 45),
            TaskModel(title: "Study SwiftUI", dueDate: Date().addingTimeInterval(3600), estimatedMinutes: 90, isCompleted: true)
        ],
        showTimerButton: true
    )
}
