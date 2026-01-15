import SwiftUI

// MARK: - Category Enum
enum TodoCategory: String, Codable, CaseIterable {
    case work = "Work"
    case personal = "Personal"
    case shopping = "Shopping"
    case health = "Health"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .work: return "briefcase.fill"
        case .personal: return "person.fill"
        case .shopping: return "cart.fill"
        case .health: return "heart.fill"
        case .other: return "folder.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .work: return .purple
        case .personal: return .blue
        case .shopping: return .green
        case .health: return .pink
        case .other: return .gray
        }
    }
}
