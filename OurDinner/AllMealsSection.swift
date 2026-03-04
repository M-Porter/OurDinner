//
//  AllMealsSection.swift
//  OurDinner
//
//  Created by Matthew Porter on 2/28/26.
//

import SwiftUI
import SwiftData

struct AllMealsSection: View {
    let meals: [Meal]
    @Binding var hasSeenSwipeHint: Bool
    @Binding var showingAddMeal: Bool

    var body: some View {
        Section {
            ForEach(meals) { meal in
                NavigationLink(value: meal) {
                    HStack {
                        Text(meal.name)
                            .font(.body)
                        Spacer()
                        ThisWeekToggle(isThisWeek: meal.isThisWeek) {
                            withAnimation {
                                meal.isThisWeek = true
                            }
                        } onHintRequest: {
                            withAnimation {
                                hasSeenSwipeHint = false
                            }
                        }
                    }
                }
                .listRowBackground(Color.rowBackground)
                .listRowSeparatorTint(Color.rowSeparator)
            }
            Button {
                showingAddMeal = true
            } label: {
                Label("Add meal...", systemImage: "plus.circle.fill")
                    .foregroundStyle(Color.primaryAccent)
            }
            .listRowBackground(Color.rowBackground)
            .listRowSeparatorTint(Color.rowSeparator)
        } header: {
            Text("All Meals")
                .font(.headline)
                .foregroundStyle(Color.primaryAccent)
                .textCase(nil)
        }
    }
}

#Preview {
    let container = try! ModelContainer(
        for: Meal.self, Ingredient.self, GroceryCheck.self,
        configurations: ModelConfiguration.appDefault(isStoredInMemoryOnly: true)
    )
    let fixtures = PreviewFixtures.seed(into: container.mainContext)

    return List {
        AllMealsSection(
            meals: fixtures.meals,
            hasSeenSwipeHint: .constant(true),
            showingAddMeal: .constant(false)
        )
    }
    .listStyle(.insetGrouped)
    .modelContainer(container)
}
