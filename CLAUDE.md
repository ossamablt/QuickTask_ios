# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a SwiftUI-based iOS todo list application with support for priorities, categories, due dates, search, and statistics tracking. Data is persisted locally using UserDefaults.

## Building and Running

Build the project:
```bash
xcodebuild -scheme tasks -configuration Debug build
```

Run in simulator (opens Xcode and builds):
```bash
open tasks.xcodeproj
```

Or build and run from command line:
```bash
xcodebuild -scheme tasks -destination 'platform=iOS Simulator,name=iPhone 15' build
```

## Architecture

The app follows MVVM architecture with a modular view structure:

### Core Components

- **Model Layer** (`Models/`): Contains the data models
  - `Todo.swift`: Main todo model with properties (title, completion status, due date, priority, category, notes, overdue logic)
  - `TodoPriority.swift`: Priority enum (low, medium, high) with associated colors and icons
  - `TodoCategory.swift`: Category enum (work, personal, shopping, health, other) with associated colors and icons
  - `TodoEnums.swift`: Filter and sort enums for UI state

- **ViewModel** (`ViewModels/`): Single view model pattern
  - `TodoViewModel`: Single source of truth for all todo state using `@Published` properties
    - Manages CRUD operations (add, update, delete, toggle)
    - Handles filtering (all/active/completed), sorting (created date, due date, priority, title), search, and category filtering
    - Computes statistics (total tasks, completion rate, overdue count)
    - Automatic persistence to UserDefaults via `didSet` on `todos` array

- **Views** (`Views/`): Main screens
  - `ContentView.swift`: Main list view with search bar, category filters, segmented filter, and sort menu
  - `AddTodoView.swift`: Sheet for creating new todos
  - `EditTodoView.swift`: Screen for editing existing todos (navigated via NavigationLink)
  - `StatisticsView.swift`: Sheet displaying task statistics

- **Components** (`components/`): Reusable UI components
  - `TodoRow.swift`: List row for displaying individual todos
  - `CategoryChip.swift`: Chip component for category filtering
  - `EmptyStateView.swift`: Empty state for filtered lists
  - `StatRow.swift`: Row component for statistics display

### Data Flow

1. `ContentView` owns a `@StateObject` of `TodoViewModel`
2. The view model is passed down to child views (AddTodoView, EditTodoView, StatisticsView)
3. All mutations go through the view model's methods
4. `@Published` properties trigger UI updates automatically
5. Changes to `todos` array automatically trigger `saveTodos()` via `didSet`

### State Management

All todo state lives in `TodoViewModel`:
- `todos`: Array of all todos (persisted)
- `filter`: Current filter (all/active/completed)
- `sortBy`: Current sort method
- `searchText`: Search query string
- `selectedCategory`: Optional category filter

The view model exposes `filteredTodos` computed property that applies all filters, search, and sorting.

## Key Implementation Details

- Persistence uses `UserDefaults` with JSON encoding/decoding (storage key: "todos_storage")
- The `Todo` model conforms to `Identifiable` and `Codable` for SwiftUI and persistence
- Overdue logic is computed in the `Todo.isOverdue` property (checks if due date has passed and task is not completed)
- Priority sorting uses custom numeric values (high=3, medium=2, low=1)
- Due date sorting prioritizes tasks with due dates over those without
- Search queries against both title and notes fields (case-insensitive)
