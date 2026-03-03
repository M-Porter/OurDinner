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
                .listRowBackground(Color.rowBackground)
                .listRowSeparatorTint(Color.primaryAccent.opacity(0.3))
            }
            Button {
                showingAddMeal = true
            } label: {
                Label("Add meal...", systemImage: "plus.circle.fill")
                    .foregroundStyle(Color.primaryAccent)
            }
            .listRowBackground(Color.rowBackground)
            .listRowSeparatorTint(Color.primaryAccent.opacity(0.3))
        } header: {
            Text("All Meals")
                .font(.headline)
                .foregroundStyle(Color.primaryAccent)
                .textCase(nil)
        }
    }
}

#Preview {
    let container = try! ModelContainer(for: Meal.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    let context = container.mainContext
    let meals = [
        Meal(name: "Pizza", isThisWeek: false),
        Meal(name: "Stir Fry", isThisWeek: false),
        Meal(name: "Pasta Carbonara", isThisWeek: true),
        Meal(name: "Burgers", isThisWeek: false),
    ]
    meals.forEach { context.insert($0) }

    return List {
        AllMealsSection(
            meals: meals,
            hasSeenSwipeHint: .constant(true),
            showingAddMeal: .constant(false)
        )
    }
    .listStyle(.insetGrouped)
    .modelContainer(container)
}
