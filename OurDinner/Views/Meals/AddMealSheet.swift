//
//  AddMealSheet.swift
//  OurDinner
//
//  Created by Matthew Porter on 2/28/26.
//

import SwiftUI
import SQLiteData

struct AddMealSheet: View {
    @Dependency(\.defaultDatabase) var database
    @Binding var isPresented: Bool

    @State private var mealName = ""
    @State private var pendingIngredientIDs: [UUID] = []
    @State private var stagedIngredients: [Ingredient] = []
    @FocusState private var mealNameFocused: Bool

    // MARK: - Actions

    private func confirmMeal() {
        let trimmed = mealName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        let meal = Meal(
            id: UUID(),
            name: trimmed,
            isThisWeek: false,
            ingredientIDs: pendingIngredientIDs
        )

        try? database.write { db in
            for ingredient in stagedIngredients {
                try Ingredient.insert { $0 = ingredient }.execute(db)
            }
            try Meal.insert { $0 = meal }.execute(db)
        }

        isPresented = false
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Meal name", text: $mealName)
                        .focused($mealNameFocused)
                } header: {
                    Text("Meal Name")
                        .foregroundStyle(Color.primaryAccent)
                        .textCase(nil)
                }

                IngredientFormSection(
                    ingredientIDs: $pendingIngredientIDs,
                    onCreateIngredient: { name in
                        let new = Ingredient(id: UUID(), name: name)
                        stagedIngredients.append(new)
                        return new.id
                    }
                )
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

// MARK: - Preview

#Preview {
    let _ = PreviewFixtures.prepare()
    AddMealSheet(isPresented: .constant(true))
}
