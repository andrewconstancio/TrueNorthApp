import SwiftUI
import Kingfisher

// MARK: Main View

struct GoalsListView: View {
    
    /// Auth environment view model
    @EnvironmentObject var viewModel: AuthViewModel
    
    /// The selected date. Default its the current date.
    @State private var selectedDate = Date()
    
    /// Show sign out activity alert.
    @State private var showingSignOutAlert = false
    
    /// The navigation path for the main views.
    @State private var path: NavigationPath = .init()
    
    /// The goal view model to handle all business logic.
    @StateObject private var goalViewModel = GoalViewModel()
    
    var allDates: [Date] {
       let calendar = Calendar.current
       let today = Date()
       return (-365...3).compactMap { dayOffset in
           calendar.date(byAdding: .day, value: dayOffset, to: today)
       }
    }
    
    var todayIndex: Int {
        let calendar = Calendar.current
        let today = Date()
        return allDates.firstIndex { calendar.isDate($0, inSameDayAs: today) } ?? 365
    }
    
    var selectedIndex: Int {
        let calendar = Calendar.current
        return allDates.firstIndex { calendar.isDate($0, inSameDayAs: selectedDate) } ?? 365
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack(alignment: .bottomTrailing) {
                VStack {
                    // Header
                    headerView
                    
                    // Day selector
                    datePickerView
                    
                    // Goals list
                    if goalViewModel.userGoals.isEmpty {
                        Text("No Goals Set")
                            .fontWeight(.bold)
                    } else {
                        goalsListView
                    }
                    Spacer()
                }
                .padding()
                
                // Show add button for
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
            .navigationDestination(for: String.self) { string in
                switch string {
                case "GoalsEditView":
                    GoalsEditView(goalViewModel: goalViewModel)
                default:
                    Text("No view has been set for \(string)")
                }
            }
            .navigationDestination(for: Int.self) { value in
                GoalDetailView(
                    goal: goalViewModel.userGoals[value],
                    goalViewModel: goalViewModel
                )
            }
        }
    }
    
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
           .frame(height: 60)
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
    }
    
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
    
    private var floatingActionButton: some View {
        NavigationLink(value: "GoalsEditView") {
            Image(systemName: "pencil")
                .font(.title2.weight(.semibold))
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(
                    Circle()
                        .fill(Color.pink)
                        .shadow(color: Color.pink.opacity(0.3), radius: 8, x: 0, y: 4)
                )
        }
     }
    
    private func isDateInFuture(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let today = Date()
        return calendar.compare(date, to: today, toGranularity: .day) == .orderedDescending
    }
    
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
