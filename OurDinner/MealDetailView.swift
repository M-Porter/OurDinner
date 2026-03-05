//
//  MealDetailView.swift
//  OurDinner
//
//  Created by Matthew Porter on 2/28/26.
//

import SwiftUI
import SQLiteData

struct MealDetailView: View {
    @State var meal: Meal

    @Dependency(\.defaultDatabase) var database
    @Environment(\.dismiss) private var dismiss
    @FetchAll(Meal.order(by: \.name)) private var allMeals: [Meal]
    @FetchAll(Ingredient.order(by: \.name)) private var allIngredients: [Ingredient]
    @FetchAll var groceryChecks: [GroceryCheck]

    @State private var stagedIngredients: [Ingredient] = []
    @State private var showingDeleteConfirmation = false

    // MARK: - Actions

    private func saveMeal() {
        try? database.write { db in
            for ingredient in stagedIngredients {
                try Ingredient.insert(ingredient).execute(db)
            }
            try Meal.update(meal).execute(db)
        }
        stagedIngredients = []
    }

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
        let ingredientLookup = Dictionary(uniqueKeysWithValues: allIngredients.map { ($0.id, $0) })

        try? database.write { db in
            // Delete orphaned ingredients and their grocery checks
            for id in orphanedIDs {
                if let ingredient = ingredientLookup[id] {
                    try Ingredient.delete(ingredient).execute(db)
                }
                if let check = groceryChecks.first(where: { $0.ingredientID == id }) {
                    try GroceryCheck.delete(check).execute(db)
                }
            }
            try Meal.delete(meal).execute(db)
        }

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

            IngredientFormSection(
                ingredientIDs: $meal.ingredientIDs,
                onCreateIngredient: { name in
                    let new = Ingredient(id: UUID(), name: name)
                    stagedIngredients.append(new)
                    return new.id
                },
                customRowBackground: true
            )

            Section {
                Button(role: .destructive) {
                    showingDeleteConfirmation = true
                } label: {
                    Text("Delete Meal")
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .listRowBackground(Color.red)
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
        .scrollContentBackground(.hidden)
        .background(Color.listBackground)
        .navigationTitle(meal.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    saveMeal()
                }
                .fontWeight(.semibold)
                .foregroundStyle(Color.actionButton)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    let db = try! PreviewFixtures.makeDatabase()
    let _ = prepareDependencies { $0.defaultDatabase = db }
    let meal = try! PreviewFixtures.seed(into: db).meals.first!

    NavigationStack {
        MealDetailView(meal: meal)
    }
}
