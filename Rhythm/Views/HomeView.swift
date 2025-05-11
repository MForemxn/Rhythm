//
//  HomeView.swift
//  Rhythm
//
//  Created by Mason Foreman on 2/5/2025.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import Foundation

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @Environment(\.dismiss) var dismiss
    
    @State private var showingTaskPopup = false
    @State private var taskDescription = ""
    @State private var estimatedMinutes: Int = 60
    @State private var dueDate: Date = Date()

    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.gray.opacity(0.2)).ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Greeting
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Welcome back,")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text(viewModel.displayName)
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(Color(hex: "#7B61FF"))
                        }
                        .padding(.top, 16)
                        .padding(.horizontal)
                        
                        // Stats Grid
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            // Total Tasks
                            DashboardStatCard(
                                title: "Total Tasks",
                                value: "\(viewModel.totalTasks)",
                                icon: "checklist",
                                color: Color(hex: "#7B61FF")
                            )
                            
                            // Completed This Week
                            DashboardStatCard(
                                title: "Completed",
                                value: "\(viewModel.completedTasks)",
                                icon: "checkmark.circle.fill",
                                color: .green
                            )
                            
                            // Yet to Complete
                            DashboardStatCard(
                                title: "To Do",
                                value: "\(viewModel.upcomingTasks)",
                                icon: "clock.fill",
                                color: .orange
                            )
                            
                            // Study Time
                            DashboardStatCard(
                                title: "Study Time",
                                value: "\(viewModel.totalStudyTime)m",
                                icon: "timer",
                                color: .blue
                            )
                        }
                        .padding(.horizontal)
                        
                        // Recent/Upcoming Tasks
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Upcoming Tasks")
                                .font(.headline)
                            if viewModel.upcomingTaskList.isEmpty {
                                Text("No upcoming tasks. Enjoy your day!")
                                    .foregroundColor(.gray)
                                    .font(.subheadline)
                            } else {
                                ForEach(viewModel.upcomingTaskList.prefix(3), id: \.self) { task in
                                    HStack {
                                        Image(systemName: task.completed ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(task.completed ? .green : .gray)
                                        Text(task.title)
                                            .fontWeight(.medium)
                                        Spacer()
                                        Text(task.dueDateString)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.vertical, 6)
                                }
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
                        .padding(.horizontal)
                        
//                        // TEMPORARY SECTION - Chloe's Timer Features for Testing
//                        VStack(alignment: .leading, spacing: 12) {
//                            Text("Timer Features Testing")
//                                .font(.headline)
//                                .foregroundColor(.orange)
//                            
//                            NavigationLink(destination: PomodoroView()) {
//                                HStack {
//                                    Image(systemName: "timer")
//                                        .foregroundColor(.white)
//                                    Text("Open Pomodoro Timer")
//                                        .fontWeight(.semibold)
//                                        .foregroundColor(.white)
//                                }
//                                .frame(maxWidth: .infinity)
//                                .padding()
//                                .background(Color.orange)
//                                .cornerRadius(12)
//                            }
//                            
//                            NavigationLink(destination: SettingsView()) {
//                                HStack {
//                                    Image(systemName: "gear")
//                                        .foregroundColor(.white)
//                                    Text("Timer Settings")
//                                        .fontWeight(.semibold)
//                                        .foregroundColor(.white)
//                                }
//                                .frame(maxWidth: .infinity)
//                                .padding()
//                                .background(Color.blue)
//                                .cornerRadius(12)
//                            }
//                            
//                            Text("Note: This section is temporary for testing")
//                                .font(.caption)
//                                .foregroundColor(.gray)
//                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
                        .padding(.horizontal)
                        
                        Spacer()
                        // Add Task Button
                        HStack {
                            Spacer()
                            Button(action: {
                                withAnimation { showingTaskPopup = true }
                            }) {
                                HStack {
                                    Image(systemName: "plus")
                                    Text("Add Task")
                                        .fontWeight(.semibold)
                                }
                                .padding()
                                .background(Color(hex: "#7B61FF"))
                                .foregroundColor(.white)
                                .cornerRadius(16)
                            }
                            Spacer()
                        }
                        .padding(.bottom, 24)
                    }
                }
                .navigationTitle("")
                .toolbar {
                    ToolbarItem(placement: .automatic) {
                        Button("Logout") {
                            viewModel.signOut()
                        }
                    }
                }
            }
            .onAppear {
                viewModel.loadUserData()
            }
        }
        .sheet(isPresented: $showingTaskPopup) {
            VStack(spacing: 16) {
                Text("New Task")
                    .font(.headline)
                    .padding(.top, -40)
                
                TextField("Enter task description", text: $taskDescription)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                    .padding(.horizontal)
                
                Spacer().frame(height: 15)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Estimated Time")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 12) {
                        ForEach([30, 60, 90, 120, 180, 240], id: \.self) { minutes in
                            Button(action: {
                                estimatedMinutes = minutes
                            }) {
                                Text(
                                    minutes >= 60 ?
                                    "\(minutes / 60)h" + (minutes % 60 == 0 ? "" : " \(minutes % 60)m") :
                                    "\(minutes)m"
                                )
                                .padding(10)
                                .frame(maxWidth: .infinity)
                                .background(estimatedMinutes == minutes ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                                .foregroundColor(.primary)
                                .cornerRadius(10)
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                Spacer().frame(height: 15)

                DatePicker("Due Date", selection: $dueDate, displayedComponents: [.date])
                    .datePickerStyle(.compact)
                    .padding(.horizontal)
                
                Spacer().frame(height: 12)

                HStack {
                    Button("Cancel") {
                        taskDescription = ""
                        showingTaskPopup = false
                    }
                    .foregroundColor(.red)

                    Spacer()

                    Button("Add") {
                        // just a placeholder for now
                        print("Task would be saved: \(taskDescription)")
                        taskDescription = ""
                        showingTaskPopup = false
                    }
                    .disabled(taskDescription.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding(.horizontal)
            }
            .padding()
            .presentationDetents([.height(500)])
        }

    }
}

struct DashboardStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    @GestureState private var isPressed = false
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
        .scaleEffect(isPressed ? 0.97 : 1)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .gesture(
            LongPressGesture(minimumDuration: 0.01)
                .updating($isPressed) { currentState, gestureState, _ in
                    gestureState = currentState
                }
        )
    }
}

struct DashboardTask: Hashable {
    let title: String
    let completed: Bool
    let dueDate: Date?
    var dueDateString: String {
        guard let dueDate = dueDate else { return "No date" }
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: dueDate)
    }
}

class HomeViewModel: ObservableObject {
    @Published var displayName: String = "User"
    @Published var totalTasks: Int = 0
    @Published var completedTasks: Int = 0
    @Published var upcomingTasks: Int = 0
    @Published var totalStudyTime: Int = 0
    @Published var upcomingTaskList: [DashboardTask] = []
    
    private let db = Firestore.firestore()
    
    func loadUserData() {
        guard let user = Auth.auth().currentUser else { return }
        
        // Fetch user data from Firestore
        fetchUserDataAsync(user: user)
        
        // Load tasks from Firestore
        loadTasks()
        
        // Load pomodoro sessions
        loadPomodoroSessions()
    }
    
    private func loadTasks() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("tasks")
            .whereField("userId", isEqualTo: userId)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self,
                      let documents = snapshot?.documents else { return }
                
                let tasks = documents.compactMap { document -> DashboardTask? in
                    let data = document.data()
                    guard let title = data["title"] as? String,
                          let completed = data["isCompleted"] as? Bool else { return nil }
                    
                    let timestamp = data["createdAt"] as? Timestamp
                    let dueDate = timestamp?.dateValue()
                    
                    return DashboardTask(title: title, completed: completed, dueDate: dueDate)
                }
                
                DispatchQueue.main.async {
                    self.totalTasks = tasks.count
                    self.completedTasks = tasks.filter { $0.completed }.count
                    self.upcomingTaskList = tasks.filter { !$0.completed }
                    self.upcomingTasks = self.upcomingTaskList.count
                }
            }
    }
    
    private func loadPomodoroSessions() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("pomodoro_sessions")
            .whereField("userId", isEqualTo: userId)
            .whereField("completed", isEqualTo: true)
            .whereField("type", isEqualTo: "focus")
            .getDocuments { [weak self] snapshot, error in
                guard let self = self,
                      let documents = snapshot?.documents else { return }
                
                let totalMinutes = documents.reduce(0) { sum, document in
                    let data = document.data()
                    let duration = data["duration"] as? TimeInterval ?? 0
                    return sum + Int(duration / 60)
                }
                
                DispatchQueue.main.async {
                    self.totalStudyTime = totalMinutes
                }
            }
    }
    
    private func fetchUserDataAsync(user: FirebaseAuth.User) {
        DispatchQueue.global().async {
            let db = self.db
            // Create a continuation to bridge between async/await and completion handlers
            let document: DocumentSnapshot
            do {
                // Use URLSession synchronously as a workaround
                let semaphore = DispatchSemaphore(value: 0)
                var docResult: DocumentSnapshot?
                var docError: Error?
                
                db.collection("users").document(user.uid).getDocument { snapshot, error in
                    docResult = snapshot
                    docError = error
                    semaphore.signal()
                }
                
                semaphore.wait()
                
                if let error = docError {
                    throw error
                }
                
                guard let document = docResult else {
                    print("No document data")
                    DispatchQueue.main.async {
                        self.displayName = user.displayName ?? "User"
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    if document.exists {
                        let data = document.data()
                        self.displayName = data?["name"] as? String ?? "User"
                    } else {
                        self.displayName = user.displayName ?? "User"
                    }
                }
            } catch {
                print("Error fetching user data: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.displayName = user.displayName ?? "User"
                }
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}

#Preview {
    HomeView()
}



