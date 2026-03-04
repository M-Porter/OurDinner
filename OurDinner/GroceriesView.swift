//
//  GroceriesView.swift
//  OurDinner
//
//  Created by Matthew Porter on 2/28/26.
//

import SwiftUI
import SwiftData

// MARK: - Internal types

private struct GroceryItem {
    let name: String
    let count: Int
}

// MARK: - View

struct GroceriesView: View {
    @Query(filter: #Predicate<Meal> { $0.isThisWeek }) private var thisWeekMeals: [Meal]
    @Query(sort: \Ingredient.name) private var allIngredients: [Ingredient]

    private var groceries: [GroceryItem] {
        // Count occurrences of each ingredient UUID across all this-week meals
        var counts: [String: Int] = [:]
        for meal in thisWeekMeals {
            for id in meal.ingredientIDs {
                counts[id, default: 0] += 1
            }
        }

        // Build a lookup from UUID string → Ingredient
        let lookup = Dictionary(uniqueKeysWithValues: allIngredients.map { ($0.id.uuidString, $0) })

        // Resolve names and sort alphabetically
        return counts.compactMap { id, count in
            guard let ingredient = lookup[id] else { return nil }
            return GroceryItem(name: ingredient.name, count: count)
        }.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    var body: some View {
        NavigationStack {
            Group {
                if thisWeekMeals.isEmpty {
                    emptyState("No meals planned this week.")
                } else if groceries.isEmpty {
                    emptyState("Your meals have no ingredients.")
                } else {
                    List {
                        Section {
                            ForEach(groceries, id: \.name) { item in
                                HStack {
                                    Text(item.name)
                                    Spacer()
                                    if item.count > 1 {
                                        Text("x\(item.count)")
                                            .foregroundStyle(.secondary)
                                            .monospacedDigit()
                                    }
                                }
                            }
                        } header: {
                            Text("This Week")
                                .foregroundStyle(Color.primaryAccent)
                                .textCase(nil)
                        }
                    }
                    .listStyle(.insetGrouped)
                    .scrollContentBackground(.hidden)
                    .background(Color.listBackground)
                }
            }
            .navigationTitle("Groceries")
        }
    }

    @ViewBuilder
    private func emptyState(_ message: String) -> some View {
        VStack {
            Spacer()
            Text(message)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Spacer()
        }
    }
}

// MARK: - Preview

#Preview {
    let container = try! ModelContainer(for: Meal.self, Ingredient.self, configurations: ModelConfiguration.appDefault(isStoredInMemoryOnly: true))
    let context = container.mainContext

    // Ingredients — some shared across meals
    let chicken  = Ingredient(name: "Chicken")
    let garlic   = Ingredient(name: "Garlic")
    let pasta    = Ingredient(name: "Pasta")
    let parmesan = Ingredient(name: "Parmesan")
    let eggs     = Ingredient(name: "Eggs")
    [chicken, garlic, pasta, parmesan, eggs].forEach { context.insert($0) }

    // Meals this week — garlic appears in both → x2
    let carbonara = Meal(name: "Pasta Carbonara", isThisWeek: true)
    carbonara.ingredientIDs = [pasta.id.uuidString, eggs.id.uuidString, parmesan.id.uuidString, garlic.id.uuidString]

    let stirFry = Meal(name: "Stir Fry", isThisWeek: true)
    stirFry.ingredientIDs = [chicken.id.uuidString, garlic.id.uuidString]

    [carbonara, stirFry].forEach { context.insert($0) }

    return GroceriesView()
        .modelContainer(container)
}
