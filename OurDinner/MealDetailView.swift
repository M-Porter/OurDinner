//
//  MealDetailView.swift
//  OurDinner
//
//  Created by Matthew Porter on 2/28/26.
//

import SwiftUI
import SwiftData

struct MealDetailView: View {
    @Bindable var meal: Meal

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Meal.name) private var allMeals: [Meal]
    @Query(sort: \Ingredient.name) private var allIngredients: [Ingredient]
    @Query private var groceryChecks: [GroceryCheck]

    @State private var showingDeleteConfirmation = false

    // MARK: - Actions

    private func deleteMeal() {
        // Ingredient IDs referenced by every other meal
        let otherMealIngredientIDs = Set(
            allMeals
                .filter { $0.id != meal.id }
                .flatMap { $0.ingredientIDs }
        )

        // Orphaned = on this meal but not referenced by any other meal
        let orphanedIDs = meal.ingredientIDs.filter { !otherMealIngredientIDs.contains($0) }

        // Build lookup to resolve ingredient IDs → Ingredient objects
        let ingredientLookup = Dictionary(uniqueKeysWithValues: allIngredients.map { ($0.id.uuidString, $0) })

        // Delete orphaned ingredients and their grocery checks
        for id in orphanedIDs {
            if let ingredient = ingredientLookup[id] {
                modelContext.delete(ingredient)
            }
            if let check = groceryChecks.first(where: { $0.ingredientID == id }) {
                modelContext.delete(check)
            }
        }

        modelContext.delete(meal)
        dismiss()
    }

    // MARK: - Body

    var body: some View {
        Form {
            Section {
                TextField("Meal name", text: $meal.name)
                    .listRowBackground(Color.rowBackground)
            } header: {
                Text("Meal Name")
                    .foregroundStyle(Color.primaryAccent)
                    .textCase(nil)
            }

            IngredientFormSection(ingredientIDs: $meal.ingredientIDs, customRowBackground: true)

            Section {
                Button("Delete Meal", role: .destructive) {
                    showingDeleteConfirmation = true
                }
                .tint(.red)
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.listBackground)
        .navigationTitle(meal.name)
        .navigationBarTitleDisplayMode(.inline)
        .overlay {
            Color.clear
                .frame(width: 0, height: 0)
                .confirmationDialog(
                    "Delete \(meal.name)?",
                    isPresented: $showingDeleteConfirmation,
                    titleVisibility: .visible
                ) {
                    Button("Delete Meal", role: .destructive) { deleteMeal() }
                    Button("Cancel", role: .cancel) { }
                } message: {
                    Text("This will permanently delete the meal and any ingredients not used by other meals.")
                }
        }
    }
}

// MARK: - Preview

#Preview {
    let container = try! ModelContainer(
        for: Meal.self, Ingredient.self, GroceryCheck.self,
        configurations: ModelConfiguration.appDefault(isStoredInMemoryOnly: true)
    )
    let fixtures = PreviewFixtures.seed(into: container.mainContext)
    let meal = fixtures.meals.first!

    return NavigationStack {
        MealDetailView(meal: meal)
    }
    .modelContainer(container)
}
