import SwiftUI

struct GoalsListDateView: View {
    let date: Date
    let isSelected: Bool
    let isFuture: Bool
    let onTap: () -> Void
    
    private var dayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "E" // Abbreviated day name (Mon, Tue, etc.)
        return formatter
    }
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d" // Day number
        return formatter.string(from: date)
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                Text(dayFormatter.string(from: date))
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(foregroundColor(for: .secondary))
                
                Text(dayNumber)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(foregroundColor(for: .primary))
            }
            .frame(width: 44, height: 60)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(backgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: isSelected ? 0 : 1)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.pink, lineWidth: Calendar.current.isDateInToday(date) && !isSelected ? 1 : 0)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isFuture)
    }
    
    private func foregroundColor(for baseColor: Color) -> Color {
        if isFuture {
            return Color.gray.opacity(0.4)
        } else if isSelected {
            return .white
        } else {
            return baseColor
        }
    }
    
    private var backgroundColor: Color {
        if isFuture {
            return Color.gray.opacity(0.1)
        } else if isSelected {
            return Color.green
        } else {
            return Color.clear
        }
    }
    
    private var borderColor: Color {
        if isFuture {
            return Color.gray.opacity(0.2)
        } else {
            return Color.gray.opacity(0.3)
        }
    }
}

