import SwiftUI
import Kingfisher

/// The main goals list view..
///
struct GoalsListView: View {
    /// Auth environment view model.
    @EnvironmentObject var viewModel: AuthViewModel
    
    /// Goal environment view model.
    @EnvironmentObject var goalViewModel: GoalViewModel
    
    /// The selected date. Default its the current date.
    @State private var selectedDate = Date()
    
    /// Show sign out activity alert.
    @State private var showingSignOutAlert = false
    
    /// The notification environment object.
    @EnvironmentObject var notificationManager: NotificationManager
    
    /// All of the dates to show in the date list.
    var allDates: [Date] {
       let calendar = Calendar.current
       let today = Date()
       return (-365...3).compactMap { dayOffset in
           calendar.date(byAdding: .day, value: dayOffset, to: today)
       }
    }
    
    /// Get the current day index in the list of all the dates.
    var todayIndex: Int {
        let calendar = Calendar.current
        let today = Date()
        return allDates.firstIndex { calendar.isDate($0, inSameDayAs: today) } ?? 365
    }
    
    /// Get the index of the selected date.
    var selectedIndex: Int {
        let calendar = Calendar.current
        return allDates.firstIndex { calendar.isDate($0, inSameDayAs: selectedDate) } ?? 365
    }
    
    var body: some View {
            ZStack(alignment: .bottomTrailing) {
                VStack {
                    headerView
                    
                    datePickerView
                    
                    if goalViewModel.userGoals.isEmpty {
                        Text("No Goals Set")
                            .fontWeight(.bold)
                    } else {
                        goalsListView
                    }
                    
                    Spacer()
                }
                .padding()
                floatingActionButton.padding()
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("Goals")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    profileButton
                }
            }
            .onAppear {
                Task {
                    try? await goalViewModel.fetchGoals(for: selectedDate)
                }
            }
            .alert("Sign Out", isPresented: $showingSignOutAlert) {
               Button("Cancel", role: .cancel) { }
               Button("Sign Out", role: .destructive) { viewModel.logout() }
            } message: {
               Text("Are you sure you want to sign out?")
            }
    }

    /// The header.
    private var headerView: some View {
        HStack {
            if let user = viewModel.currentUser {
                Text("\(user.firstName) \(user.lastName)")
                    .fontWeight(.bold)
                    .font(.caption)
            }
            
            Spacer()
            Text(formatDate(selectedDate))
                .fontWeight(.bold)
                .font(.caption)
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
                           isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate),
                           isFuture: isDateInFuture(date),
                       ) {
                           selectedDate = date
                           
                           // Fetch goal data for the date
                           Task {
                               do {
                                   try await goalViewModel.fetchGoals(for: date)
                               } catch {
                                   throw error
                               }
                           }
                       }
                       .id(index)
                   }
               }
               .padding(.horizontal)
           }
           .onChange(of: selectedDate) { _ in
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
    
    /// The list of the users goals.
    private var goalsListView: some View {
        List {
            ForEach(goalViewModel.userGoals.indices, id: \.self) { index in
                GoalRowView(
                    goal: goalViewModel.userGoals[index],
                    goalIndex: index,
                    selectedDate: selectedDate
                )
            }
        }
        .listStyle(.plain)
        .refreshable {
            try? await goalViewModel.fetchGoals(for: selectedDate)
        }
    }
    
    /// The profile picture button.
    private var profileButton: some View {
         Group {
             if let user = viewModel.currentUser,
                let urlString = user.profileImageUrl,
                let url = URL(string: urlString) {
                 Button {
                     showingSignOutAlert = true
                 } label: {
                     KFImage(url)
                         .resizable()
                         .scaledToFill()
                         .clipShape(Circle())
                         .frame(width: 36, height: 36)
                         .overlay(
                             Circle()
                                 .stroke(Color.gray.opacity(0.2), lineWidth: 1)
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
    
    /// The add a new goal floating button.
    private var floatingActionButton: some View {
        NavigationLink(value: "GoalsEditView") {
            Image(systemName: "pencil")
                .font(.title2.weight(.semibold))
                .foregroundColor(.white)
                .frame(width: 62, height: 62)
                .background(
                    Circle()
                        .fill(Color.pink)
                        .shadow(color: Color.pink.opacity(0.3), radius: 8, x: 0, y: 4)
                )
        }
     }
    
    // MARK: Private functions.
    
    /// Check if a date is in the future.
    private func isDateInFuture(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let today = Date()
        return calendar.compare(date, to: today, toGranularity: .day) == .orderedDescending
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
