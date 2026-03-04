//
//  MealDetailView.swift
//  OurDinner
//
//  Created by Matthew Porter on 3/3/26.
//

import SwiftUI
import SwiftData

struct MealDetailView: View {
    @Bindable var meal: Meal

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
        }
        .scrollContentBackground(.hidden)
        .background(Color.listBackground)
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
