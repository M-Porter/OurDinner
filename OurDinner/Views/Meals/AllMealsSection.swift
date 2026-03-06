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
    @Binding var selectedMeal: Meal?
    var onToggle: (Meal) -> Void

    var body: some View {
        Section {
            ForEach(meals) { meal in
                Button {
                    selectedMeal = meal
                } label: {
                    HStack {
                        Text(meal.name)
                            .font(.body)
                            .foregroundStyle(Color.primary)
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
                .buttonStyle(.plain)
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
            selectedMeal: .constant(nil),
            onToggle: { _ in }
        )
    }
    .listStyle(.insetGrouped)
}
