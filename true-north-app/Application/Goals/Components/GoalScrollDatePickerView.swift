import SwiftUI

struct GoalScrollDatePickerView: View {
    
    /// The auth view model.
    @EnvironmentObject var authVM: AuthViewModel
    
    /// The goal view model.
    @EnvironmentObject var goalVM: GoalViewModel
    
    private var allDates: [Date] {
       let calendar = Calendar.current
       let today = Date()
        return (-(authVM.authState.currentUser?.daysSinceCreated ?? 0)...7).compactMap { dayOffset in
           calendar.date(byAdding: .day, value: dayOffset, to: today)
       }
    }
    
    private var todayIndex: Int {
        let calendar = Calendar.current
        let today = Date()
        return allDates.firstIndex { calendar.isDate($0, inSameDayAs: today) } ?? 365
    }
    
    private var selectedIndex: Int {
        let calendar = Calendar.current
        return allDates.firstIndex { calendar.isDate($0, inSameDayAs: goalVM.selectedDate) } ?? 365
    }
    
    var body: some View {
        ScrollViewReader { proxy in
           ScrollView(.horizontal, showsIndicators: false) {
               LazyHStack(spacing: 12) {
                   ForEach(Array(allDates.enumerated()), id: \.offset) { index, date in
                       GoalsListDateView(
                           date: date,
                           isSelected: Calendar.current.isDate(date, inSameDayAs: goalVM.selectedDate),
                           isFuture: date.isDateInFuture(),
                           onTap: {
                               Task {
                                   let impact = UIImpactFeedbackGenerator(style: .soft)
                                   impact.impactOccurred()
                                   goalVM.selectedDate = date
                                   await goalVM.fetchGoals()
                               }
                           }
                       )
                       .id(index)
                   }
               }
               .padding(.horizontal)
           }
           .frame(height: 80)
           .onAppear {
               DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                   withAnimation(.easeInOut(duration: 0.5)) {
                       proxy.scrollTo(selectedIndex, anchor: .center)
                   }
               }
           }
       }
       .padding(.vertical, 10)
    }
}

#Preview {
    GoalScrollDatePickerView()
}
