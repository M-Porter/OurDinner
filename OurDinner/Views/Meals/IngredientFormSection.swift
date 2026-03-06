//
//  IngredientFormSection.swift
//  OurDinner
//
//  Created by Matthew Porter on 3/3/26.
//

import SwiftUI
import SQLiteData

struct IngredientFormSection: View {
    @FetchAll(Ingredient.order(by: \.name)) private var allIngredients: [Ingredient]

    @Binding var ingredientIDs: [UUID]
    var stagedIngredients: [Ingredient] = []
    /// Called when the user confirms a brand-new ingredient name that doesn't exist yet.
    /// The closure should create and stage the ingredient, then return its ID.
    var onCreateIngredient: (String) -> UUID

    @State private var ingredientQuery = ""
    @FocusState private var ingredientFieldFocused: Bool

    // MARK: - Computed

    private var currentIngredients: [Ingredient] {
        let fromDB = Dictionary(uniqueKeysWithValues: allIngredients.map { ($0.id, $0) })
        let fromStaged = Dictionary(uniqueKeysWithValues: stagedIngredients.map { ($0.id, $0) })
        let lookup = fromDB.merging(fromStaged) { _, staged in staged }
        return ingredientIDs.compactMap { lookup[$0] }
    }

    private func normalized(_ s: String) -> String {
        s.filter { !$0.isWhitespace }.lowercased()
    }

    private var suggestions: [Ingredient] {
        guard !ingredientQuery.trimmingCharacters(in: .whitespaces).isEmpty else { return [] }
        let query = normalized(ingredientQuery)
        return allIngredients.filter { ingredient in
            normalized(ingredient.name).contains(query) &&
            !ingredientIDs.contains(ingredient.id)
        }.prefix(5).map { $0 }
    }

    private var hasExactMatch: Bool {
        let query = normalized(ingredientQuery)
        return allIngredients.contains { normalized($0.name) == query }
    }

    // MARK: - Actions

    private func addIngredientFromQuery() {
        let trimmed = ingredientQuery.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        // Skip if already added
        if currentIngredients.contains(where: { normalized($0.name) == normalized(trimmed) }) {
            ingredientQuery = ""
            return
        }

        // Reuse existing ingredient or create a new one via callback
        if let existing = allIngredients.first(where: { normalized($0.name) == normalized(trimmed) }) {
            ingredientIDs.append(existing.id)
        } else {
            let newID = onCreateIngredient(trimmed)
            ingredientIDs.append(newID)
        }
        ingredientQuery = ""
    }

    private func addSuggestion(_ ingredient: Ingredient) {
        guard !ingredientIDs.contains(ingredient.id) else { return }
        ingredientIDs.append(ingredient.id)
        ingredientQuery = ""
        ingredientFieldFocused = true
    }

    // MARK: - Body

    var body: some View {
        Section {
            // Current ingredients — swipe to remove
            ForEach(currentIngredients, id: \.id) { ingredient in
                Text(ingredient.name)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            ingredientIDs.removeAll { $0 == ingredient.id }
                        } label: {
                            Label("Remove", systemImage: "minus.circle")
                        }
                        .tint(.red)
                    }
            }

            // Text field row
            TextField("Add ingredient...", text: $ingredientQuery)
                .focused($ingredientFieldFocused)
                .onSubmit { addIngredientFromQuery() }

            // Suggestion rows
            ForEach(suggestions) { ingredient in
                Button {
                    addSuggestion(ingredient)
                } label: {
                    Label {
                        Text(ingredient.name)
                            .foregroundStyle(.primary)
                    } icon: {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)
                    }
                }
                .listRowBackground(Color.rowBackground)
            }

            // "Add new" row when no exact match
            if !hasExactMatch && !ingredientQuery.trimmingCharacters(in: .whitespaces).isEmpty {
                Button {
                    addIngredientFromQuery()
                } label: {
                    Label {
                        Text("Add \"\(ingredientQuery.trimmingCharacters(in: .whitespaces))\"")
                            .foregroundStyle(Color.primaryAccent)
                    } icon: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(Color.primaryAccent)
                    }
                }
                .listRowBackground(Color.rowBackground)
            }
        } header: {
            Text("Ingredients")
                .foregroundStyle(Color.primaryAccent)
                .textCase(nil)
        }
    }
}

// MARK: - Preview

#Preview {
    let db = PreviewFixtures.prepare()
    let fixtures = try! PreviewFixtures.seed(into: db)
    let meal = fixtures.meals.first!

    Form {
        IngredientFormSection(
            ingredientIDs: .constant(meal.ingredientIDs),
            onCreateIngredient: { _ in UUID() }
        )
    }
}
