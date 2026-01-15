
import SwiftUI

// MARK: - Content View
struct ContentView: View {
    @StateObject private var viewModel = TodoViewModel()
    @State private var showingAddSheet = false
    @State private var showingStatsSheet = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search tasks...", text: $viewModel.searchText)
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
                            viewModel.selectedCategory = nil
                        }
                        
                        ForEach(TodoCategory.allCases, id: \.self) { category in
                            CategoryChip(
                                title: category.rawValue,
                                icon: category.icon,
                                color: category.color,
                                isSelected: viewModel.selectedCategory == category
                            ) {
                                viewModel.selectedCategory = category
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 8)
                
                // Filter and Sort
                HStack {
                    Picker("Filter", selection: $viewModel.filter) {
                        ForEach(TodoFilter.allCases, id: \.self) {
                            Text($0.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    Menu {
                        Picker("Sort By", selection: $viewModel.sortBy) {
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
                if viewModel.filteredTodos.isEmpty {
                    EmptyStateView(filter: viewModel.filter)
                } else {
                    List {
                        ForEach(viewModel.filteredTodos) { todo in
                            NavigationLink {
                                EditTodoView(todo: todo, viewModel: viewModel)
                            } label: {
                                TodoRow(todo: todo) {
                                    viewModel.toggle(todo)
                                }
                            }
                        }
                        .onDelete(perform: viewModel.delete)
                    }
                    .listStyle(.plain)
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
                AddTodoView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingStatsSheet) {
                StatisticsView(viewModel: viewModel)
            }
        }
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
