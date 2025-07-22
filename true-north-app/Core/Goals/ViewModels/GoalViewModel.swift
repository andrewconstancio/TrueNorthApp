//
//  GoalViewModel.swift
//  true-north-app
//
//  Created by Andrew Constancio on 7/7/25.
//
import SwiftUI
import Firebase
import FirebaseAuth

class GoalViewModel: ObservableObject {
    @Published var userGoals: [Goal] = []
    private let service = GoalService()
    
    func saveGoal(title: String, description: String, term: String, endDate: Date, category: String, selectedColor: Color) async throws {
        do {
            guard let color = selectedColor.toHex() else { return }
            try await service.saveGoal(title: title, description: description, term: term, endDate: endDate, color: color)
        } catch {
            throw error
        }
    }
    
    @MainActor
    func fetchGoals(for selectedDate : Date) async throws {
        do {
            self.userGoals = try await service.fetchGoals(for: selectedDate)
        } catch {
            throw error
        }
    }
    
    func saveProgress(for goalId: String) async throws {
        do {
            try await service.saveProgress(for: goalId)
        } catch {
            throw error
        }
    }
}
