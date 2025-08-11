import SwiftUI
import Kingfisher

/// The main goals list view..
///
struct GoalsListView: View {
    /// Auth environment view model.
    @EnvironmentObject var viewModel: AuthViewModel
    
    /// Goal environment view model.
    @EnvironmentObject var goalViewModel: GoalViewModel
    
    /// The notification environment object.
    @EnvironmentObject var notificationManager: NotificationManager
    
    /// Show sign out activity alert.
    @State private var showingSignOutAlert = false
    
    /// The error of this view.
    @State private var currentError: AppError?
    
    /// If true show the error alert. 
    @State private var showingErrorAlert = false
    
    /// The category of the goal selected.
    @State private var categorySelected: GoalCategories?
    
    /// Goals that are filtered through the selector.
    private var filteredGoals: [Goal] {
        if let selected = categorySelected {
            return goalViewModel.goals.filter { $0.category == selected.rawValue.capitalized }
        } else {
            return goalViewModel.goals
        }
    }
    
    /// All of the dates to show in the date list.
    private var allDates: [Date] {
       let calendar = Calendar.current
       let today = Date()
       return (-365...3).compactMap { dayOffset in
           calendar.date(byAdding: .day, value: dayOffset, to: today)
       }
    }
    
    /// Get the current day index in the list of all the dates.
    private var todayIndex: Int {
        let calendar = Calendar.current
        let today = Date()
        return allDates.firstIndex { calendar.isDate($0, inSameDayAs: today) } ?? 365
    }
    
    /// Get the index of the selected date.
    private var selectedIndex: Int {
        let calendar = Calendar.current
        return allDates.firstIndex { calendar.isDate($0, inSameDayAs: goalViewModel.selectedDate) } ?? 365
    }
    
    var body: some View {
            ZStack(alignment: .bottomTrailing) {
                VStack {
                    headerView
                    datePickerView
                    
                    if goalViewModel.goals.isEmpty {
                        noGoalText
                    } else {
                        categorySelector
                        goalsListView
                    }
                    Spacer()
                }
                .padding()
                
                floatingActionButton
            }
            .background(.backgroundPrimary)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("Goals")
                        .font(FontManager.Bungee.regular.font(size: 36))
                        .foregroundStyle(.textPrimary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    profileButton
                }
            }
            .onAppear {
                fetchGoals()
            }
            .signOutAlert(isPresented: $showingSignOutAlert) {
                try? viewModel.logout()
            }
            .errorAlert(isPresented: $showingErrorAlert, error: currentError)
    }
    
    private func fetchGoals() {
        Task {
            do {
                try await goalViewModel.fetchGoals()
            } catch {
                currentError = .networkError("Failed to fetch data.")
                showingErrorAlert = true
            }
        }
    }

    /// The header.
    private var headerView: some View {
        HStack {
            if let user = viewModel.authState.currentUser {
                Text("\(user.firstName) \(user.lastName)")
                    .font(FontManager.Bungee.regular.font(size: 18))
                    .foregroundStyle(.textBlack)
            }
            
            Spacer()
            Text(formatDate(goalViewModel.selectedDate))
                .font(FontManager.Bungee.regular.font(size: 14))
                .foregroundStyle(.textBlack)
        }
    }
    
    /// The date picker.
    private var datePickerView: some View {
        ScrollViewReader { proxy in
           ScrollView(.horizontal, showsIndicators: false) {
               LazyHStack(spacing: 12) {
                   ForEach(Array(allDates.enumerated()), id: \.offset) { index, date in
                       GoalsListDateView(
                           date: date,
                           isSelected: Calendar.current.isDate(date, inSameDayAs: goalViewModel.selectedDate),
                           isFuture: isDateInFuture(date),
                       ) {
                           goalViewModel.selectedDate = date
                           fetchGoals()
                       }
                       .id(index)
                   }
               }
               .padding(.horizontal)
           }
           .onChange(of: goalViewModel.selectedDate) { _ in
               let impact = UIImpactFeedbackGenerator(style: .soft)
               impact.impactOccurred()
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
    
    private var categorySelector: some View {
        HStack {
            Spacer()
            Menu {
                Picker(selection: $categorySelected) {
                    Text("All").tag(GoalCategories?.none)
                    ForEach(GoalCategories.allCases, id: \.self) { category in
                        Text(category.rawValue.capitalized)
                            .tag(category)
                    }
                } label: {}
            } label: {
                HStack {
                    Text(categorySelected?.rawValue.capitalized ?? "All".capitalized)
                        .font(FontManager.Bungee.regular.font(size: 14))
                        .foregroundStyle(.textBlack)
                    
                    Image(systemName: "chevron.down")
                        .resizable()
                        .frame(width: 14, height: 10)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.textBlack)
                }
                .padding(8)
                .background(.sunglow)
                .clipShape(.capsule)
            }
        }
    }
    
    /// The list of the users goals.
    @ViewBuilder
    private var goalsListView: some View {
        if filteredGoals.isEmpty {
            noGoalText
        } else {
            List {
                ForEach(filteredGoals) { goal in
                    GoalRowView(
                        goal: goal,
                        selectedDate: goalViewModel.selectedDate,
                        isPastDate: isDateInPast(goalViewModel.selectedDate)
                    )
                }
            }
            .listStyle(.plain)
            .refreshable {
                fetchGoals()
            }
        }
    }
    
    /// The profile picture button.
    private var profileButton: some View {
         Group {
             if let user = viewModel.authState.currentUser,
                let urlString = user.profileImageUrl,
                let url = URL(string: urlString) {
                 Button {
                     showingSignOutAlert = true
                 } label: {
                     KFImage(url)
                         .resizable()
                         .scaledToFill()
                         .clipShape(Circle())
                         .frame(width: 42, height: 42)
                         .overlay(
                            Circle()
                                .stroke(Color.sunglow, lineWidth: 3)
                         )
                 }
             } else {
                 Button {
                     showingSignOutAlert = true
                 } label: {
                     Image(systemName: "person.circle.fill")
                         .font(.title2)
                         .foregroundColor(.gray)
                 }
             }
         }
    }
    
    /// The no goals text.
    private var noGoalText: some View {
        Text("No Goals")
            .font(FontManager.Bungee.regular.font(size: 28))
            .foregroundStyle(.textPrimary)
    }
    
    /// The add a new goal floating button.
    private var floatingActionButton: some View {
        NavigationLink(value: AppRoutes.goalEdit) {
            Image(systemName: "pencil")
                .font(.title2.weight(.semibold))
                .foregroundColor(.textPrimary)
                .frame(width: 68, height: 68)
                .background(
                    Circle()
                        .fill(.utOrange)
                        .shadow(color: .utOrange.opacity(0.2), radius: 8, x: 0, y: 4)
                )
                .padding()
        }
    }
    
    /// Check if a date is in the future.
    private func isDateInFuture(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let today = Date()
        return calendar.compare(date, to: today, toGranularity: .day) == .orderedDescending
    }
    
    /// Check if a date is in the past.
    private func isDateInPast(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let today = Date()
        return calendar.compare(date, to: today, toGranularity: .day) == .orderedAscending
    }

    /// Format a date.
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: date)
    }
}

#Preview {
    GoalsListView()
}
