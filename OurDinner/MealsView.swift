//
//  MealsView.swift
//  OurDinner
//
//  Created by Matthew Porter on 2/28/26.
//

import SwiftUI
import SwiftData

struct MealsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Meal.name) private var meals: [Meal]
    @Query private var groceryChecks: [GroceryCheck]

    @State private var showingAddMeal = false
    @AppStorage("hasSeenSwipeHint") private var hasSeenSwipeHint = false

    private var thisWeekMeals: [Meal] {
        meals.filter { $0.isThisWeek }
    }

    private func removeMealFromThisWeek(_ meal: Meal) {
        meal.isThisWeek = false

        // Collect ingredient IDs still referenced by remaining This Week meals
        let remainingIDs = Set(
            meals
                .filter { $0.isThisWeek && $0.id != meal.id }
                .flatMap { $0.ingredientIDs }
        )

        // Delete checks for ingredients that are no longer in any This Week meal
        for ingredientID in meal.ingredientIDs where !remainingIDs.contains(ingredientID) {
            if let check = groceryChecks.first(where: { $0.ingredientID == ingredientID }) {
                modelContext.delete(check)
            }
        }
    }

    var body: some View {
        NavigationStack {
            List {
                ThisWeekSection(
                    thisWeekMeals: thisWeekMeals,
                    hasSeenSwipeHint: $hasSeenSwipeHint,
                    onRemove: removeMealFromThisWeek
                )
                AllMealsSection(
                    meals: meals,
                    hasSeenSwipeHint: $hasSeenSwipeHint,
                    showingAddMeal: $showingAddMeal
                )
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Color.listBackground)
            .navigationTitle("Meals")
            .navigationDestination(for: Meal.self) { meal in
                MealDetailView(meal: meal)
            }
            .sheet(isPresented: $showingAddMeal) {
                AddMealSheet(isPresented: $showingAddMeal)
            }
        }
    }
}

// MARK: - This Week Toggle Button

struct ThisWeekToggle: View {
    let isThisWeek: Bool
    let action: () -> Void
    var onHintRequest: (() -> Void)? = nil

    var body: some View {
        if isThisWeek {
            Button(action: { onHintRequest?() }) {
                Text("✓ This Week")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.primaryAccent)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.primaryAccent.opacity(0.12))
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        } else {
            Button(action: action) {
                Image(systemName: "plus.circle")
                    .font(.title2)
                    .foregroundStyle(Color.primaryAccent)
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    MealsView()
        .modelContainer(PreviewFixtures.makeContainer())
}
