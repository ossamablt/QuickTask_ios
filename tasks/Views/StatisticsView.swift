import SwiftUI

// MARK: - Statistics View
struct StatisticsView: View {
    let viewModel: TodoListViewModel
    let todos: [Todo]
    @Environment(\.dismiss) private var dismiss

    private var stats: (total: Int, completed: Int, active: Int, overdue: Int, completionRate: Double) {
        viewModel.calculateStatistics(todos: todos)
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Overview") {
                    StatRow(title: "Total Tasks", value: "\(stats.total)")
                    StatRow(title: "Active Tasks", value: "\(stats.active)")
                    StatRow(title: "Completed Tasks", value: "\(stats.completed)")
                    StatRow(title: "Overdue Tasks", value: "\(stats.overdue)",
                           valueColor: stats.overdue > 0 ? .red : nil)
                }

                Section("Progress") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Completion Rate")
                            Spacer()
                            Text(String(format: "%.1f%%", stats.completionRate))
                                .fontWeight(.semibold)
                        }

                        ProgressView(value: stats.completionRate, total: 100)
                            .tint(.green)
                    }
                    .padding(.vertical, 4)
                }

                Section("By Category") {
                    ForEach(TodoCategory.allCases, id: \.self) { category in
                        let count = todos.filter { $0.category == category }.count
                        HStack {
                            Label(category.rawValue, systemImage: category.icon)
                                .foregroundColor(category.color)
                            Spacer()
                            Text("\(count)")
                                .foregroundColor(.secondary)
                        }
                    }
                }

                Section("By Priority") {
                    ForEach(TodoPriority.allCases, id: \.self) { priority in
                        let count = todos.filter { $0.priority == priority }.count
                        HStack {
                            Label(priority.rawValue, systemImage: priority.icon)
                                .foregroundColor(priority.color)
                            Spacer()
                            Text("\(count)")
                                .foregroundColor(.secondary)
                        }
                    }
                }

                if stats.completed > 0 {
                    Section {
                        Button(role: .destructive) {
                            viewModel.clearCompleted(todos: todos)
                            dismiss()
                        } label: {
                            HStack {
                                Spacer()
                                Text("Clear Completed Tasks")
                                Spacer()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
