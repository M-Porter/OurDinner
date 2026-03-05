//
//  GroceriesView.swift
//  OurDinner
//
//  Created by Matthew Porter on 2/28/26.
//

import SwiftUI
import SQLiteData

// MARK: - Internal types

private struct GroceryItem {
    let id: UUID  // ingredient UUID
    let name: String
    let count: Int
}

// MARK: - View

struct GroceriesView: View {
    @Dependency(\.defaultDatabase) var database

    @FetchAll(Meal.where(\.isThisWeek)) private var thisWeekMeals: [Meal]
    @FetchAll(Ingredient.order(by: \.name)) private var allIngredients: [Ingredient]
    @FetchAll var checkedItems: [GroceryCheck]

    private var checkedIDs: Set<UUID> {
        Set(checkedItems.map { $0.ingredientID })
    }

    private var groceries: [GroceryItem] {
        // Count occurrences of each ingredient UUID across all this-week meals
        var counts: [UUID: Int] = [:]
        for meal in thisWeekMeals {
            for id in meal.ingredientIDs {
                counts[id, default: 0] += 1
            }
        }

        // Build a lookup from UUID → Ingredient
        let lookup = Dictionary(uniqueKeysWithValues: allIngredients.map { ($0.id, $0) })

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

    private func toggleCheck(ingredientID: UUID) {
        if let existing = checkedItems.first(where: { $0.ingredientID == ingredientID }) {
            try? database.write { db in
                try GroceryCheck.delete(existing).execute(db)
            }
        } else {
            try? database.write { db in
                try GroceryCheck.insert(GroceryCheck(ingredientID: ingredientID)).execute(db)
            }
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Preview

#Preview {
    let _ = prepareDependencies {
        $0.defaultDatabase = try! PreviewFixtures.makeDatabase()
    }
    GroceriesView()
}
