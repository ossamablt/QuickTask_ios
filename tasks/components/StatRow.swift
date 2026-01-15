import SwiftUI

// MARK: - Stat Row
struct StatRow: View {
    let title: String
    let value: String
    var valueColor: Color?
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
                .foregroundColor(valueColor ?? .primary)
        }
    }
}
