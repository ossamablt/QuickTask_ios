//
//  MainNavigationView.swift
//  tasks
//
//  Adaptive navigation that switches between iPhone and iPad layouts
//

import SwiftUI
import SwiftData

struct MainNavigationView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        if horizontalSizeClass == .compact {
            // iPhone: Standard NavigationStack
            TodoListView()
        } else {
            // iPad: NavigationSplitView with sidebar
            iPadNavigationView()
        }
    }
}

// MARK: - iPad Navigation

struct iPadNavigationView: View {
    @State private var selectedSection: SidebarSection? = .allTasks
    @State private var columnVisibility: NavigationSplitViewVisibility = .all

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            SidebarView(selectedSection: $selectedSection)
        } detail: {
            if let section = selectedSection {
                DetailViewForSection(section: section)
            } else {
                Text("Select a section")
                    .font(.title)
                    .foregroundColor(.secondary)
            }
        }
        .navigationSplitViewStyle(.balanced)
    }
}

// MARK: - Sidebar

enum SidebarSection: String, CaseIterable, Identifiable {
    case allTasks = "All Tasks"
    case today = "Today"
    case work = "Work"
    case personal = "Personal"
    case shopping = "Shopping"
    case health = "Health"
    case other = "Other"
    case highPriority = "High Priority"
    case mediumPriority = "Medium Priority"
    case lowPriority = "Low Priority"
    case statistics = "Statistics"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .allTasks: return "square.grid.2x2"
        case .today: return "calendar.badge.clock"
        case .work: return "briefcase.fill"
        case .personal: return "person.fill"
        case .shopping: return "cart.fill"
        case .health: return "heart.fill"
        case .other: return "ellipsis.circle.fill"
        case .highPriority: return "exclamationmark.3"
        case .mediumPriority: return "exclamationmark.2"
        case .lowPriority: return "exclamationmark"
        case .statistics: return "chart.bar.fill"
        }
    }

    var color: Color {
        switch self {
        case .allTasks: return .blue
        case .today: return .orange
        case .work: return .blue
        case .personal: return .purple
        case .shopping: return .green
        case .health: return .pink
        case .other: return .gray
        case .highPriority: return .red
        case .mediumPriority: return .orange
        case .lowPriority: return .green
        case .statistics: return .blue
        }
    }
}

struct SidebarView: View {
    @Binding var selectedSection: SidebarSection?

    var body: some View {
        List(selection: $selectedSection) {
            Section("Quick Filters") {
                ForEach([SidebarSection.allTasks, .today]) { section in
                    NavigationLink(value: section) {
                        Label(section.rawValue, systemImage: section.icon)
                            .foregroundColor(section.color)
                    }
                }
            }

            Section("Categories") {
                ForEach([SidebarSection.work, .personal, .shopping, .health, .other]) { section in
                    NavigationLink(value: section) {
                        Label(section.rawValue, systemImage: section.icon)
                            .foregroundColor(section.color)
                    }
                }
            }

            Section("Priority") {
                ForEach([SidebarSection.highPriority, .mediumPriority, .lowPriority]) { section in
                    NavigationLink(value: section) {
                        Label(section.rawValue, systemImage: section.icon)
                            .foregroundColor(section.color)
                    }
                }
            }

            Section {
                NavigationLink(value: SidebarSection.statistics) {
                    Label("Statistics", systemImage: "chart.bar.fill")
                        .foregroundColor(.blue)
                }
            }
        }
        .navigationTitle("Tasks")
        .listStyle(.sidebar)
    }
}

// MARK: - Detail View

struct DetailViewForSection: View {
    let section: SidebarSection

    var body: some View {
        switch section {
        case .statistics:
            StatisticsDetailView()
        default:
            FilteredTodoListView(section: section)
        }
    }
}

struct FilteredTodoListView: View {
    let section: SidebarSection

    var body: some View {
        TodoListView()
            .navigationTitle(section.rawValue)
            .navigationBarTitleDisplayMode(.large)
    }
}

struct StatisticsDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allTodos: [Todo]

    @State private var viewModel: TodoListViewModel?

    var body: some View {
        Group {
            if let viewModel = viewModel {
                statsContent(viewModel: viewModel)
            } else {
                ProgressView()
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = TodoListViewModel(modelContext: modelContext)
            }
        }
    }

    @ViewBuilder
    private func statsContent(viewModel: TodoListViewModel) -> some View {
        let stats = viewModel.calculateStatistics(todos: allTodos)

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

            categorySection
            prioritySection
        }
        .navigationTitle("Statistics")
    }

    private var categorySection: some View {
        Section("By Category") {
            ForEach(TodoCategory.allCases, id: \.self) { category in
                categoryRow(category: category)
            }
        }
    }

    private func categoryRow(category: TodoCategory) -> some View {
        let count = allTodos.filter { $0.category == category }.count
        return HStack {
            Label(category.rawValue, systemImage: category.icon)
                .foregroundColor(category.color)
            Spacer()
            Text("\(count)")
                .foregroundColor(.secondary)
        }
    }

    private var prioritySection: some View {
        Section("By Priority") {
            ForEach(TodoPriority.allCases, id: \.self) { priority in
                priorityRow(priority: priority)
            }
        }
    }

    private func priorityRow(priority: TodoPriority) -> some View {
        let count = allTodos.filter { $0.priority == priority }.count
        return HStack {
            Label(priority.rawValue, systemImage: priority.icon)
                .foregroundColor(priority.color)
            Spacer()
            Text("\(count)")
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Preview

#Preview("iPhone") {
    MainNavigationView()
        .modelContainer(for: Todo.self, inMemory: true)
        .environment(\.horizontalSizeClass, .compact)
}

#Preview("iPad") {
    MainNavigationView()
        .modelContainer(for: Todo.self, inMemory: true)
        .environment(\.horizontalSizeClass, .regular)
}
