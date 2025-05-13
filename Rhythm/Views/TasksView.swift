import SwiftUI

struct TasksView: View {
    let title: String
    let showTimerButton: Bool
    @ObservedObject var viewModel: HomeViewModel

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.largeTitle)
                    .bold()
                    .padding()

                if filteredTasks.isEmpty {
                    Text("No tasks to display.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List {
                        ForEach(filteredTasks.indices, id: \.self) { index in
                            let task = filteredTasks[index]

                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Button(action: {
                                        toggleTaskCompletion(task)
                                    }) {
                                        Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(task.isCompleted ? .green : .gray)
                                    }
                                    Text(task.title)
                                        .fontWeight(.medium)
                                }

                                Text("Due: \(task.dueDate.formatted(date: .abbreviated, time: .shortened))")
                                    .font(.caption)
                                    .foregroundColor(.gray)

                                Text("Est: \(task.estimatedMinutes) min")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)

                                if showTimerButton && !task.isCompleted {
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
            }
            .navigationTitle(title)
        }
    }

    private var filteredTasks: [TaskModel] {
        if title.contains("Completed") {
            return viewModel.tasks.filter { $0.isCompleted }
        } else if title.contains("To Do") {
            return viewModel.tasks.filter { !$0.isCompleted }
        } else {
            return viewModel.tasks
        }
    }

    private func toggleTaskCompletion(_ task: TaskModel) {
        if let index = viewModel.tasks.firstIndex(where: { $0.id == task.id }) {
            viewModel.tasks[index].isCompleted.toggle()
            viewModel.saveTasks()
            viewModel.updateStatsAndUpcomingList()
        }
    }
}
