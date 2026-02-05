import SwiftUI

// MARK: - Empty State
struct EmptyStateView: View {
    let filter: TodoFilter
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text(emptyMessage)
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyMessage: String {
        switch filter {
        case .all: return "No tasks yet"
        case .active: return "No active tasks"
        case .completed: return "No completed tasks"
        }
    }
}
