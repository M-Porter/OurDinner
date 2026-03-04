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
    let id: String  // ingredient UUID string
    let name: String
    let count: Int
}

// MARK: - View

struct GroceriesView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(filter: #Predicate<Meal> { $0.isThisWeek }) private var thisWeekMeals: [Meal]
    @Query(sort: \Ingredient.name) private var allIngredients: [Ingredient]
    @Query private var checkedItems: [GroceryCheck]

    private var checkedIDs: Set<String> {
        Set(checkedItems.map { $0.ingredientID })
    }

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

        // Resolve names, then sort: unchecked first, then alphabetical within each group
        return counts.compactMap { id, count in
            guard let ingredient = lookup[id] else { return nil }
            return GroceryItem(id: id, name: ingredient.name, count: count)
        }.sorted {
            let aChecked = checkedIDs.contains($0.id)
            let bChecked = checkedIDs.contains($1.id)
            if aChecked != bChecked { return !aChecked }
            return $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
        }
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
                            ForEach(groceries, id: \.id) { item in
                                let isChecked = checkedIDs.contains(item.id)
                                Button {
                                    toggleCheck(ingredientID: item.id)
                                } label: {
                                    HStack(spacing: 12) {
                                        Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                                            .font(.title3)
                                            .foregroundStyle(isChecked ? Color.primaryAccent : .secondary)

                                        Text(item.name)
                                            .font(.body)
                                            .foregroundStyle(isChecked ? .secondary : .primary)
                                            .strikethrough(isChecked, color: .secondary)

                                        Spacer()

                                        if item.count > 1 && !isChecked {
                                            Text("x\(item.count)")
                                                .foregroundStyle(.secondary)
                                                .monospacedDigit()
                                        }
                                    }
                                }
                                .buttonStyle(.plain)
                                .listRowBackground(Color.rowBackground)
                                .listRowSeparatorTint(Color.primaryAccent.opacity(0.3))
                                .animation(.default, value: checkedIDs)
                            }
                        } header: {
                            Text("This Week")
                                .font(.headline)
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

    // MARK: - Actions

    private func toggleCheck(ingredientID: String) {
        if let existing = checkedItems.first(where: { $0.ingredientID == ingredientID }) {
            modelContext.delete(existing)
        } else {
            modelContext.insert(GroceryCheck(ingredientID: ingredientID))
        }
    }

    // MARK: - Empty state

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
    let container = try! ModelContainer(for: Meal.self, Ingredient.self, GroceryCheck.self, configurations: ModelConfiguration.appDefault(isStoredInMemoryOnly: true))
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

    // Pre-check one item so the checked state is visible in preview
    context.insert(GroceryCheck(ingredientID: eggs.id.uuidString))

    return GroceriesView()
        .modelContainer(container)
}
