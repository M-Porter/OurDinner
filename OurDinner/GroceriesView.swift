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

        // Resolve names and sort alphabetically
        return counts.compactMap { id, count in
            guard let ingredient = lookup[id] else { return nil }
            return GroceryItem(id: id, name: ingredient.name, count: count)
        }.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    private var uncheckedGroceries: [GroceryItem] {
        groceries.filter { !checkedIDs.contains($0.id) }
    }

    private var checkedGroceries: [GroceryItem] {
        groceries.filter { checkedIDs.contains($0.id) }
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
                            if uncheckedGroceries.isEmpty {
                                Text("All done!")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .listRowBackground(Color.rowBackground)
                            } else {
                                ForEach(uncheckedGroceries, id: \.id) { item in
                                    groceryRow(item: item, isChecked: false)
                                }
                            }
                        } header: {
                            Text("This Week")
                                .font(.headline)
                                .foregroundStyle(Color.primaryAccent)
                                .textCase(nil)
                        }

                        if !checkedGroceries.isEmpty {
                            Section {
                                ForEach(checkedGroceries, id: \.id) { item in
                                    groceryRow(item: item, isChecked: true)
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .scrollContentBackground(.hidden)
                    .background(Color.listBackground)
                }
            }
            .background(Color.listBackground)
            .navigationTitle("Groceries")
        }
    }

    // MARK: - Row

    @ViewBuilder
    private func groceryRow(item: GroceryItem, isChecked: Bool) -> some View {
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
        .listRowSeparatorTint(Color.rowSeparator)
        .animation(.default, value: checkedIDs)
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
    GroceriesView()
        .modelContainer(PreviewFixtures.makeContainer())
}
