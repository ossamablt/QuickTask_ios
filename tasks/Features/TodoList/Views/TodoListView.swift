//
//  TodoListView.swift
//  tasks
//
//  Main todo list view with SwiftData integration
//

import SwiftUI
import SwiftData

struct TodoListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allTodos: [Todo]

    @State private var viewModel: TodoListViewModel?
    @State private var showingAddSheet = false
    @State private var showingStatsSheet = false

    // MARK: - Computed Properties

    private var filteredTodos: [Todo] {
        guard let viewModel = viewModel else { return [] }

        var result = allTodos

        // Apply filter
        switch viewModel.filter {
        case .all:
            break
        case .active:
            result = result.filter { !$0.isCompleted }
        case .completed:
            result = result.filter { $0.isCompleted }
        }

        // Apply category filter
        if let category = viewModel.selectedCategory {
            result = result.filter { $0.category == category }
        }

        // Apply search
        if !viewModel.searchText.isEmpty {
            result = result.filter {
                $0.title.localizedCaseInsensitiveContains(viewModel.searchText) ||
                $0.notes.localizedCaseInsensitiveContains(viewModel.searchText)
            }
        }

        // Apply sorting
        switch viewModel.sortBy {
        case .createdDate:
            result.sort { $0.createdAt > $1.createdAt }
        case .dueDate:
            result.sort { (todo1, todo2) in
                if let date1 = todo1.dueDate, let date2 = todo2.dueDate {
                    return date1 < date2
                } else if todo1.dueDate != nil {
                    return true
                } else {
                    return false
                }
            }
        case .priority:
            result.sort { (todo1, todo2) in
                let priority1 = viewModel.priorityValue(todo1.priority)
                let priority2 = viewModel.priorityValue(todo2.priority)
                return priority1 > priority2
            }
        case .title:
            result.sort { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        }

        return result
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if let viewModel = viewModel {
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search tasks...", text: Binding(
                            get: { viewModel.searchText },
                            set: { viewModel.searchText = $0 }
                        ))
                        if !viewModel.searchText.isEmpty {
                            Button {
                                viewModel.searchText = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding()

                    // Category Filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            CategoryChip(
                                title: "All",
                                icon: "square.grid.2x2",
                                color: .blue,
                                isSelected: viewModel.selectedCategory == nil
                            ) {
                                HapticService.shared.selectionChanged()
                                viewModel.selectedCategory = nil
                            }

                            ForEach(TodoCategory.allCases, id: \.self) { category in
                                CategoryChip(
                                    title: category.rawValue,
                                    icon: category.icon,
                                    color: category.color,
                                    isSelected: viewModel.selectedCategory == category
                                ) {
                                    HapticService.shared.selectionChanged()
                                    viewModel.selectedCategory = category
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 8)

                    // Filter and Sort
                    HStack {
                        Picker("Filter", selection: Binding(
                            get: { viewModel.filter },
                            set: { viewModel.filter = $0 }
                        )) {
                            ForEach(TodoFilter.allCases, id: \.self) {
                                Text($0.rawValue)
                            }
                        }
                        .pickerStyle(.segmented)

                        Menu {
                            Picker("Sort By", selection: Binding(
                                get: { viewModel.sortBy },
                                set: { viewModel.sortBy = $0 }
                            )) {
                                ForEach(TodoSort.allCases, id: \.self) { sort in
                                    Label(sort.rawValue, systemImage: "arrow.up.arrow.down")
                                        .tag(sort)
                                }
                            }
                        } label: {
                            Image(systemName: "arrow.up.arrow.down.circle")
                                .font(.title3)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)

                    // List
                    if filteredTodos.isEmpty {
                        EmptyStateView(filter: viewModel.filter)
                    } else {
                        List {
                            ForEach(filteredTodos) { todo in
                                NavigationLink {
                                    EditTodoView(todo: todo, viewModel: viewModel)
                                } label: {
                                    TodoRow(todo: todo) {
                                        viewModel.toggleCompletion(todo)
                                    }
                                }
                            }
                            .onDelete { indexSet in
                                for index in indexSet {
                                    viewModel.deleteTodo(filteredTodos[index])
                                }
                            }
                        }
                        .listStyle(.plain)
                    }
                }
            }
            .navigationTitle("My Tasks")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingStatsSheet = true
                    } label: {
                        Image(systemName: "chart.bar.fill")
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                if let viewModel = viewModel {
                    AddTodoView(viewModel: viewModel)
                }
            }
            .sheet(isPresented: $showingStatsSheet) {
                if let viewModel = viewModel {
                    StatisticsView(viewModel: viewModel, todos: allTodos)
                }
            }
            .onAppear {
                if viewModel == nil {
                    viewModel = TodoListViewModel(modelContext: modelContext)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    TodoListView()
        .modelContainer(for: Todo.self, inMemory: true)
}
