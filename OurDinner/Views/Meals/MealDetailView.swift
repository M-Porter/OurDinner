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
    @State private var originalMeal: Meal

    @Dependency(\.defaultDatabase) var database
    @Environment(\.dismiss) private var dismiss
    @FetchAll(Meal.order(by: \.name)) private var allMeals: [Meal]
    @FetchAll(Ingredient.order(by: \.name)) private var allIngredients: [Ingredient]
    @FetchAll var groceryChecks: [GroceryCheck]

    @State private var stagedIngredients: [Ingredient] = []
    @State private var showingDeleteConfirmation = false
    @State private var showingDiscardConfirmation = false

    init(meal: Meal) {
        _meal = State(initialValue: meal)
        _originalMeal = State(initialValue: meal)
    }

    // MARK: - Actions

    private var hasChanges: Bool {
        !stagedIngredients.isEmpty || meal != originalMeal
    }

    private func saveMeal() {
        try? database.write { db in
            for ingredient in stagedIngredients {
                try Ingredient.insert { ingredient }.execute(db)
            }
            try Meal.update(meal.saving()).execute(db)
        }
        stagedIngredients = []
        originalMeal = meal
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
                stagedIngredients: stagedIngredients,
                onCreateIngredient: { name in
                    let new = Ingredient.create(name: name)
                    stagedIngredients.append(new)
                    return new.id
                },
                customRowBackground: true
            )
        }
        .scrollContentBackground(.hidden)
        .background(Color.listBackground)
        .navigationTitle(meal.name)
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(hasChanges)
        .confirmationDialog(
            "Discard changes?",
            isPresented: $showingDiscardConfirmation,
            titleVisibility: .visible
        ) {
            Button("Discard Changes", role: .destructive) { dismiss() }
            Button("Keep Editing", role: .cancel) { }
        } message: {
            Text("If you go back now, you will lose your changes.")
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                if hasChanges {
                    Button {
                        showingDiscardConfirmation = true
                    } label: {
                        Image(systemName: "chevron.left")
                    }
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Button("Save") {
                    saveMeal()
                }
                .fontWeight(.medium)
                .disabled(!hasChanges)
            }
            ToolbarItem(placement: .destructiveAction) {
                Button(role: .destructive) {
                    showingDeleteConfirmation = true
                } label: {
                    Label("Delete", systemImage: "trash")
                }
                .tint(.red)
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
}

// MARK: - Preview

#Preview {
    let db = PreviewFixtures.prepare()
    let meal = try! PreviewFixtures.seed(into: db).meals.first!

    NavigationStack {
        MealDetailView(meal: meal)
    }
}
