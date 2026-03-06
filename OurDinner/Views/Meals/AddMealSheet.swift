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

    private func saveMeal() {
        let trimmed = mealName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        let meal = Meal.create(name: trimmed, ingredientIDs: pendingIngredientIDs)

        try? database.write { db in
            for ingredient in stagedIngredients {
                try Ingredient.insert { ingredient }.execute(db)
            }
            try Meal.insert { meal }.execute(db)
        }

        isPresented = false
    }

    private func canSaveMeal() -> Bool {
        return !mealName.trimmingCharacters(in: .whitespaces).isEmpty
            && stagedIngredients.count > 0
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
                }

                IngredientFormSection(
                    ingredientIDs: $pendingIngredientIDs,
                    stagedIngredients: stagedIngredients,
                    onCreateIngredient: { name in
                        let new = Ingredient.create(name: name)
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
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        saveMeal()
                    }
                    .fontWeight(.semibold)
                    .disabled(!canSaveMeal())
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
