//
//  AddMealSheet.swift
//  OurDinner
//
//  Created by Matthew Porter on 2/28/26.
//

import SwiftUI
import SwiftData

struct AddMealSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var isPresented: Bool

    // Meal name
    @State private var mealName = ""
    @FocusState private var mealNameFocused: Bool

    // Ingredient input
    @State private var ingredientQuery = ""
    @State private var pendingIngredients: [Ingredient] = []
    @FocusState private var ingredientFieldFocused: Bool

    // All existing ingredients for suggestions
    @Query(sort: \Ingredient.name) private var allIngredients: [Ingredient]

    // MARK: - Normalization

    private func normalized(_ s: String) -> String {
        s.filter { !$0.isWhitespace }.lowercased()
    }

    private var suggestions: [Ingredient] {
        guard !ingredientQuery.trimmingCharacters(in: .whitespaces).isEmpty else { return [] }
        let query = normalized(ingredientQuery)
        return allIngredients.filter { ingredient in
            normalized(ingredient.name).contains(query) &&
            !pendingIngredients.contains(where: { $0.name == ingredient.name })
        }.prefix(5).map { $0 }
    }

    private var hasExactMatch: Bool {
        let query = normalized(ingredientQuery)
        return allIngredients.contains { normalized($0.name) == query }
            || pendingIngredients.contains { normalized($0.name) == query }
    }

    // MARK: - Actions

    private func addIngredientFromQuery() {
        let trimmed = ingredientQuery.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        // If exact match exists in pending, skip
        if pendingIngredients.contains(where: { normalized($0.name) == normalized(trimmed) }) {
            ingredientQuery = ""
            return
        }

        // If exact match exists in store, reuse it
        if let existing = allIngredients.first(where: { normalized($0.name) == normalized(trimmed) }) {
            pendingIngredients.append(existing)
        } else {
            pendingIngredients.append(Ingredient(name: trimmed))
        }
        ingredientQuery = ""
    }

    private func addSuggestion(_ ingredient: Ingredient) {
        guard !pendingIngredients.contains(where: { $0.name == ingredient.name }) else { return }
        pendingIngredients.append(ingredient)
        ingredientQuery = ""
        ingredientFieldFocused = true
    }

    private func confirmMeal() {
        let trimmed = mealName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        let meal = Meal(name: trimmed)
        modelContext.insert(meal)

        for ingredient in pendingIngredients {
            // Insert new ingredients, existing ones are already in the store
            if ingredient.modelContext == nil {
                modelContext.insert(ingredient)
            }
            meal.ingredients.append(ingredient)
        }

        isPresented = false
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Form {
                // Meal name
                Section {
                    TextField("Meal name", text: $mealName)
                        .focused($mealNameFocused)
                } header: {
                    Text("Meal Name")
                        .foregroundStyle(Color.primaryAccent)
                        .textCase(nil)
                }

                // Ingredients
                Section {
                    // Added ingredients — swipe to delete
                    ForEach(pendingIngredients, id: \.name) { ingredient in
                        Text(ingredient.name)
                            .listRowBackground(Color.rowBackground)
                    }
                    .onDelete { offsets in
                        pendingIngredients.remove(atOffsets: offsets)
                    }

                    // Text field row
                    TextField("Add ingredient...", text: $ingredientQuery)
                        .focused($ingredientFieldFocused)
                        .onSubmit { addIngredientFromQuery() }
                        .listRowBackground(Color.rowBackground)

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
            .navigationTitle("Add Meal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .foregroundStyle(Color.primaryAccent)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        confirmMeal()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(mealName.trimmingCharacters(in: .whitespaces).isEmpty
                                     ? Color.secondary
                                     : Color.actionButton)
                    .disabled(mealName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear { mealNameFocused = true }
        }
    }
}

#Preview {
    let container = try! ModelContainer(for: Meal.self, Ingredient.self, configurations: ModelConfiguration.appDefault(isStoredInMemoryOnly: true))
    let context = container.mainContext

    // Seed some existing ingredients
    ["Pasta", "Pancetta", "Parmesan", "Eggs", "Chicken", "Garlic"].forEach {
        context.insert(Ingredient(name: $0))
    }

    return AddMealSheet(isPresented: .constant(true))
        .modelContainer(container)
}
