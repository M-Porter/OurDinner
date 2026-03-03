//
//  ThisWeekSection.swift
//  OurDinner
//
//  Created by Matthew Porter on 2/28/26.
//

import SwiftUI
import SwiftData

struct ThisWeekSection: View {
    let thisWeekMeals: [Meal]
    @Binding var hasSeenSwipeHint: Bool

    var body: some View {
        Section {
            if thisWeekMeals.isEmpty {
                Text("No meals added yet")
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
                    .listRowBackground(Color.rowBackground)
            } else {
                if !hasSeenSwipeHint {
                    HStack(spacing: 10) {
                        Image(systemName: "hand.draw.fill")
                            .font(.subheadline)
                            .foregroundStyle(Color.primaryAccent)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Tip: Remove a meal")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.primaryAccent)
                            Text("Swipe left on a meal to remove it from this week")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Button {
                            withAnimation {
                                hasSeenSwipeHint = true
                            }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.subheadline)
                                .foregroundStyle(Color.primaryAccent.opacity(0.4))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.vertical, 4)
                    .listRowBackground(Color.hintRowBackground)
                }
                ForEach(thisWeekMeals) { meal in
                    Text(meal.name)
                        .font(.body)
                        .listRowBackground(Color.rowBackground)
                        .listRowSeparatorTint(Color.primaryAccent.opacity(0.3))
                        .swipeActions(edge: .trailing) {
                            Button {
                                withAnimation {
                                    meal.isThisWeek = false
                                }
                            } label: {
                                Label { Text("Remove").fontWeight(.semibold) } icon: { Image(systemName: "minus.circle") }
                            }
                            .tint(Color.hintBackground)
                        }
                }
            }
        } header: {
            Text("This Week")
                .font(.headline)
                .foregroundStyle(Color.primaryAccent)
                .textCase(nil)
        }
    }
}

#Preview {
    let container = try! ModelContainer(for: Meal.self, Ingredient.self, configurations: ModelConfiguration.appDefault(isStoredInMemoryOnly: true))
    let context = container.mainContext
    context.insert(Meal(name: "Pasta Carbonara", isThisWeek: true))
    context.insert(Meal(name: "Tacos", isThisWeek: true))

    return List {
        ThisWeekSection(thisWeekMeals: [
            Meal(name: "Pasta Carbonara", isThisWeek: true),
            Meal(name: "Tacos", isThisWeek: true),
        ], hasSeenSwipeHint: .constant(false))
    }
    .listStyle(.insetGrouped)
    .modelContainer(container)
}
