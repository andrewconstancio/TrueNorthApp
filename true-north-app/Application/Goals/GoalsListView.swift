import SwiftUI

/// The main goals list view.
///
struct GoalsListView: View {
    /// Auth view model.
    @EnvironmentObject var authVM: AuthViewModel
    
    /// Goal view model.
    @EnvironmentObject var goalVM: GoalViewModel
    
    /// Flag to show the settings sheet.
    @State private var showSettingSheet = false
    
    /// Flag to show the calendar sheet.
    @State private var showCalendarSheet = false
    
    /// Goal Category selected.
    @State private var categorySelected: GoalCategories?
    
    /// Goals filtered by the category.
    private var filteredGoals: [Goal] {
        if let selected = categorySelected {
            return goalVM.goals.filter { $0.category == selected.rawValue.capitalized }
        } else {
            return goalVM.goals
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                VStack {
                    headerView
                    GoalScrollDatePickerView()
                    
                    if goalVM.goals.isEmpty {
                        noGoalText
                    } else {
                        categorySelector
                        goalsListView
                    }
                    Spacer()
                }
                .padding(.top)
            }
            .scrollIndicators(.hidden)
            
            floatingActionButton
        }
        .background(Color.backgroundPrimary.ignoresSafeArea())
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
            Task {
                await goalVM.fetchGoals()
            }
        }
        .sheet(isPresented: $showSettingSheet) {
            SettingsView()
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(24)
        }
        .sheet(isPresented: $showCalendarSheet) {
            CalendarView()
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(24)
        }
        .errorAlert(isPresented: $goalVM.showAppError, error: goalVM.appError)
    }

    /// The users name and current date.
    private var headerView: some View {
        VStack(alignment: .trailing, spacing: 8) {
            HStack {
                if let user = authVM.authState.currentUser {
                    Text("\(user.firstName) \(user.lastName)")
                        .font(FontManager.Bungee.regular.font(size: 18))
                        .foregroundStyle(.textSecondary)
                }
                
                Spacer()
                Text(goalVM.selectedDate.formatDate())
                    .font(FontManager.Bungee.regular.font(size: 14))
                    .foregroundStyle(.textSecondary)
            }
            
            Button {
                showCalendarSheet = true
            } label: {
                Image(systemName: "calendar")
                    .resizable()
                    .foregroundStyle(.textPrimary)
                    .frame(width: 18, height: 18, alignment: .leading)
            }
        }
        .padding(.horizontal)
    }
    
    /// Goal category picker.
    private var categorySelector: some View {
        HStack {
            // Reset the goal category filter.
            if categorySelected != nil {
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        categorySelected = nil
                    }
                } label: {
                    Text("Reset")
                        .font(FontManager.Bungee.regular.font(size: 14))
                        .foregroundStyle(.textBlack)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(.blue)
                        .clipShape(Capsule())
                        .shadow(radius: 2)
                }
                .transition(.asymmetric(
                    insertion: .scale.combined(with: .opacity),
                    removal: .opacity
                ))
            }
            
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
        .padding(.horizontal)
    }
    
    /// The list of the users goals.
    @ViewBuilder
    private var goalsListView: some View {
        if filteredGoals.isEmpty {
            noGoalText
        } else {
            VStack {
                ForEach(filteredGoals) { goal in
                    GoalRowView(
                        goal: goal,
                        selectedDate: $goalVM.selectedDate
                    )
                    
                    /// Navigate to the goal detail view.
                    .onTapGesture {
                        /// If its not the current day do not allow click into.
                        if !goalVM.selectedDate.isDateInPast() {
                            authVM.appPath.append(goal)
                        }
                    }
                }
            }
            .padding(.horizontal, 4)
        }
    }
    
    /// The profile picture button.
    @ViewBuilder
    private var profileButton: some View {
        Button {
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            
            showSettingSheet = true
        } label: {
            if let user = authVM.authState.currentUser,
               let urlString = user.profileImageUrl,
               let url = URL(string: urlString) {
                AsyncCachedImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .clipShape(Circle())
                        .frame(width: 38, height: 38)
                        .overlay(
                           Circle()
                               .stroke(Color.sunglow, lineWidth: 3)
                        )
                } placeholder: {
                    ProgressView()
                }
            } else {
                Image(systemName: "person.circle.fill")
                    .font(.title2)
                    .foregroundColor(.gray)
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
        NavigationLink(value: AppRoutes.goalAddVew) {
            Image(systemName: "plus")
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
        .onTapGesture {
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
        }
    }
}

#Preview {
    NavigationStack {
        GoalsListView()
            .environmentObject(AuthViewModel())
            .environmentObject(GoalViewModel())
    }
}
