import SwiftUI

struct GoalsListDateView: View {
    let date: Date
    let isSelected: Bool
    let isFuture: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .center, spacing: 4) {
                
                // Goals completed indicator
                Circle()
                    .stroke(Color.blue, lineWidth: 1)
                    .frame(width: 8, height: 8)
             
                VStack(spacing: 4) {
                    // The day name
                    Text(dayFormatter.string(from: date))
                        .font(FontManager.Bungee.regular.font(size: 14))
                        .foregroundStyle(.textPrimary)
                    
                    // The day number
                    Text(dayNumber)
                        .font(FontManager.Bungee.regular.font(size: 14))
                        .foregroundStyle(.textPrimary)
                }
                .frame(width: 44, height: 65)
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
                        .stroke(.spaceCadet, lineWidth: Calendar.current.isDateInToday(date) ? 1 : 0)
                )
            }
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isFuture)
    }
    
    
    // MARK: Private functions
    
    /// Day formatter
    private var dayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter
    }
    
    /// Day number
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    /// Date foreground color
    private func foregroundColor(for baseColor: Color) -> Color {
        if isFuture {
            return Color.gray.opacity(0.4)
        } else if isSelected {
            return .white
        } else {
            return baseColor
        }
    }
    
    /// Date background color
    private var backgroundColor: Color {
        if isFuture {
            return Color.utOrange.opacity(0.1)
        } else if isSelected {
            return Color.utOrange
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

