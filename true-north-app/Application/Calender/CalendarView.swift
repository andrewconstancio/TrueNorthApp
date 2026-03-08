import SwiftUI
import HorizonCalendar

struct CalendarView: View {
    
    /// The auth view model environment object.
    @EnvironmentObject var authVM: AuthViewModel
    
    /// The calendar view model.
    @ObservedObject var calendarVM: CalendarViewModel
    
    /// The calendar object the `HorizonCalendar` takes in.
    let calendar = Calendar.current
    
    init(calendarVM: CalendarViewModel) {
        self.calendarVM = calendarVM
    }

    /// The start date of the calendar is when the account is create.
    private var startDate: Date {
        guard let dateCreated = authVM.authState.currentUser?.dateCreated.dateValue() else {
           return Date()
        }
        let components = calendar.dateComponents([.year, .month, .day], from: dateCreated)
        return calendar.date(from: components) ?? Date()
    }

    /// The calendar should go up to the current date.
    private var currentDate = Date()
    
    @State private var scrollToCurrentMonth = false
    
    var body: some View {
        VStack {
            Spacer().frame(height: 50)
            customCalendar
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.backgroundPrimary.ignoresSafeArea())
        .errorAlert(isPresented: $calendarVM.showAppError, error: calendarVM.appError)
    }
    
    /// Custom calendar from `HorizonCalendar`.
    private var customCalendar: some View {
        GeometryReader { geometry in
            CalendarViewRepresentable(
                calendar: calendar,
                visibleDateRange: startDate...currentDate,
                monthsLayout: .vertical(options: VerticalMonthsLayoutOptions()),
                dataDependency: scrollToCurrentMonth
            )
            .monthHeaders { month in
                monthHeader(month)
                    .onAppear {
                        Task {
                            await calendarVM.fetchDaysCompleted(for: month.components)
                        }
                    }
            }
            .dayOfWeekHeaders { _, weekdayIndex in
                dayOfWeekHeader(weekdayIndex)
            }
            .days { day in
                calendarDay(day)
            }
            .interMonthSpacing(24)
            .verticalDayMargin(16)
            .horizontalDayMargin(4)
            .layoutMargins(.init(top: 8, leading: 8, bottom: 8, trailing: 8))
            .backgroundColor(UIColor(Color.clear))
            .padding()
            .onAppear {
                // Use introspection to find and scroll the internal UIScrollView
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    scrollToCurrentMonth.toggle()
                    
                    // Try to find and scroll the UIScrollView
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = windowScene.windows.first {
                        findAndScrollToBottom(in: window)
                    }
                }
            }
        }
    }
    
    /// Helper function to find UIScrollView and scroll to bottom
    private func findAndScrollToBottom(in view: UIView) {
        for subview in view.subviews {
            if let scrollView = subview as? UIScrollView,
               scrollView.contentSize.height > 0 {
                let bottomOffset = CGPoint(
                    x: 0,
                    y: scrollView.contentSize.height - scrollView.bounds.height + scrollView.contentInset.bottom
                )
                scrollView.setContentOffset(bottomOffset, animated: true)
                return
            }
            findAndScrollToBottom(in: subview)
        }
    }
    
    /// Calendar month header.
    /// - Parameter month: The month date components.
    /// - Returns: The view.
    private func monthHeader(_ month: MonthComponents) -> some View {
        let monthNames = [
            1: "January", 2: "February", 3: "March", 4: "April",
            5: "May", 6: "June", 7: "July", 8: "August",
            9: "September", 10: "October", 11: "November", 12: "December"
        ]
        
        let monthName = monthNames[month.month] ?? "Unknown"
        let yearString = String(format: "%d", month.year)
        
        return Text("\(monthName) \(yearString)")
            .foregroundStyle(.textPrimary)
            .font(FontManager.Bungee.regular.font(size: 22))
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    /// Day of the week header.
    /// - Parameter weekdayIndex: The number index for the day of the week.
    /// - Returns: The view.
    private func dayOfWeekHeader(_ weekdayIndex: Int) -> some View {
        let monthNames = [
            0: "S", 1: "M", 2: "T", 3: "W", 4: "TH",
            5: "F", 6: "S"
        ]
        
        return AnyView(
            Text("\(String(monthNames[weekdayIndex] ?? ""))")
                .font(FontManager.Bungee.regular.font(size: 14))
                .foregroundColor(.textSecondary)
        )
    }
    
    /// Calendar date.
    /// - Parameter day: The day date components.
    /// - Returns: The view.
    private func calendarDay(_ day: DayComponents) -> some View {
        
        let calendar = Calendar.current
        let currentDay = calendar.dateComponents([.year, .month, .day], from: Date())
        var isPast = false
        var completedDay = false

        if let dayDate = calendar.date(from: day.components),
           let currentDate = calendar.date(from: currentDay) {
            if dayDate <= currentDate {
                isPast = true
                completedDay = calendarVM.completedDays[dayDate] ?? false
            }
        }
        
        return AnyView(
            VStack {
                Text("\(day.day)")
                    .font(FontManager.Bungee.regular.font(size: 14))
                    .foregroundColor(.textPrimary)

                if completedDay {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 12, height: 12)
                } else if isPast {
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 12, height: 12)
                } else {
                    Circle()
                        .stroke(Color.blue, lineWidth: 1)
                        .frame(width: 12, height: 12)
                }
            }
            .padding(.vertical, 6)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                if !isPast {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.backgroundLighter.opacity(0.5))
                }
            }
        )
    }
}

//#Preview {
//    CalendarView(a)
//        .environmentObject(AuthViewModel())
//}
