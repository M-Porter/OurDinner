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

    @State private var mealName = ""
    @State private var pendingIngredientIDs: [String] = []
    @FocusState private var mealNameFocused: Bool

    // MARK: - Actions

    private func confirmMeal() {
        let trimmed = mealName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        let meal = Meal(name: trimmed)
        meal.ingredientIDs = pendingIngredientIDs
        modelContext.insert(meal)

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

                IngredientFormSection(ingredientIDs: $pendingIngredientIDs)
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
    let container = try! ModelContainer(
        for: Meal.self, Ingredient.self, GroceryCheck.self,
        configurations: ModelConfiguration.appDefault(isStoredInMemoryOnly: true)
    )
    PreviewFixtures.seed(into: container.mainContext)

    return AddMealSheet(isPresented: .constant(true))
        .modelContainer(container)
}
