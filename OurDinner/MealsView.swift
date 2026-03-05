//
//  MealsView.swift
//  OurDinner
//
//  Created by Matthew Porter on 2/28/26.
//

import SwiftUI
import SQLiteData

struct MealsView: View {
    @Dependency(\.defaultDatabase) var database
    @FetchAll(Meal.order(by: \.name)) private var meals: [Meal]
    @FetchAll var groceryChecks: [GroceryCheck]

    @State private var showingAddMeal = false
    @AppStorage("hasSeenSwipeHint") private var hasSeenSwipeHint = false

    private var thisWeekMeals: [Meal] {
        meals.filter { $0.isThisWeek }
    }

    private func removeMealFromThisWeek(_ meal: Meal) {
        // Collect ingredient IDs still referenced by remaining This Week meals
        let remainingIDs = Set(
            meals
                .filter { $0.isThisWeek && $0.id != meal.id }
                .flatMap { $0.ingredientIDs }
        )

        // Checks to delete: ingredients leaving This Week entirely
        let checksToDelete = groceryChecks.filter { check in
            meal.ingredientIDs.contains(check.ingredientID) &&
            !remainingIDs.contains(check.ingredientID)
        }

        var updated = meal
        updated.isThisWeek = false

        try? database.write { db in
            for check in checksToDelete {
                try GroceryCheck.delete(check).execute(db)
            }
            try Meal.update(updated).execute(db)
        }
    }

    private func addMealToThisWeek(_ meal: Meal) {
        var updated = meal
        updated.isThisWeek = true
        try? database.write { db in
            try Meal.update(updated).execute(db)
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
                    showingAddMeal: $showingAddMeal,
                    onToggle: addMealToThisWeek
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
    let _ = prepareDependencies {
        $0.defaultDatabase = try! PreviewFixtures.makeDatabase()
    }
    MealsView()
}
