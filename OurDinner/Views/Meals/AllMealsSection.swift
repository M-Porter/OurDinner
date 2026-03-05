//
//  AllMealsSection.swift
//  OurDinner
//
//  Created by Matthew Porter on 2/28/26.
//

import SwiftUI

struct AllMealsSection: View {
    let meals: [Meal]
    @Binding var hasSeenSwipeHint: Bool
    @Binding var showingAddMeal: Bool
    var onToggle: (Meal) -> Void

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
                                onToggle(meal)
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

// MARK: - Preview

#Preview {
    let db = PreviewFixtures.prepare()

    List {
        AllMealsSection(
            meals: try! PreviewFixtures.seed(into: db).meals,
            hasSeenSwipeHint: .constant(true),
            showingAddMeal: .constant(false),
            onToggle: { _ in }
        )
    }
    .listStyle(.insetGrouped)
}
