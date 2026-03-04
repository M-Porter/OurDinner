//
//  MealDetailView.swift
//  OurDinner
//
//  Created by Matthew Porter on 3/3/26.
//

import SwiftUI
import SwiftData

struct MealDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var meal: Meal

    @Query(sort: \Ingredient.name) private var allIngredients: [Ingredient]

    @State private var ingredientQuery = ""
    @FocusState private var ingredientFieldFocused: Bool

    // MARK: - Computed

    private var mealIngredients: [Ingredient] {
        let lookup = Dictionary(uniqueKeysWithValues: allIngredients.map { ($0.id.uuidString, $0) })
        return meal.ingredientIDs.compactMap { lookup[$0] }
    }

    private func normalized(_ s: String) -> String {
        s.filter { !$0.isWhitespace }.lowercased()
    }

    private var suggestions: [Ingredient] {
        guard !ingredientQuery.trimmingCharacters(in: .whitespaces).isEmpty else { return [] }
        let query = normalized(ingredientQuery)
        return allIngredients.filter { ingredient in
            normalized(ingredient.name).contains(query) &&
            !meal.ingredientIDs.contains(ingredient.id.uuidString)
        }.prefix(5).map { $0 }
    }

    private var hasExactMatch: Bool {
        let query = normalized(ingredientQuery)
        return allIngredients.contains { normalized($0.name) == query && meal.ingredientIDs.contains($0.id.uuidString) }
            || allIngredients.contains { normalized($0.name) == query }
    }

    // MARK: - Actions

    private func addIngredientFromQuery() {
        let trimmed = ingredientQuery.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        // Skip if already on this meal
        if mealIngredients.contains(where: { normalized($0.name) == normalized(trimmed) }) {
            ingredientQuery = ""
            return
        }

        // Reuse existing ingredient or create new one
        if let existing = allIngredients.first(where: { normalized($0.name) == normalized(trimmed) }) {
            meal.ingredientIDs.append(existing.id.uuidString)
        } else {
            let new = Ingredient(name: trimmed)
            modelContext.insert(new)
            meal.ingredientIDs.append(new.id.uuidString)
        }
        ingredientQuery = ""
    }

    private func addSuggestion(_ ingredient: Ingredient) {
        guard !meal.ingredientIDs.contains(ingredient.id.uuidString) else { return }
        meal.ingredientIDs.append(ingredient.id.uuidString)
        ingredientQuery = ""
        ingredientFieldFocused = true
    }

    // MARK: - Body

    var body: some View {
        Form {
            // Meal name
            Section {
                TextField("Meal name", text: $meal.name)
            } header: {
                Text("Meal Name")
                    .foregroundStyle(Color.primaryAccent)
                    .textCase(nil)
            }

            // Ingredients
            Section {
                ForEach(mealIngredients, id: \.id) { ingredient in
                    Text(ingredient.name)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                meal.ingredientIDs.removeAll { $0 == ingredient.id.uuidString }
                            } label: {
                                Label("Remove", systemImage: "minus.circle")
                            }
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
                }
            } header: {
                Text("Ingredients")
                    .foregroundStyle(Color.primaryAccent)
                    .textCase(nil)
            }
        }
        .navigationTitle(meal.name)
        .navigationBarTitleDisplayMode(.inline)
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
