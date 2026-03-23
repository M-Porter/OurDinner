//
//  ThisWeekSection.swift
//  PrixFixe
//
//  Created by Matthew Porter on 2/28/26.
//

import SwiftUI

struct ThisWeekSection: View {
    let thisWeekMeals: [Meal]
    @Binding var hasSeenSwipeHint: Bool
    var onRemove: (Meal) -> Void

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
                                .foregroundStyle(Color.primaryAccent.opacity(0.6))
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
                        .listRowSeparatorTint(Color.rowSeparator)
                        .swipeActions(edge: .trailing) {
                            Button {
                                withAnimation {
                                    onRemove(meal)
                                }
                            } label: {
                                Label { Text("Remove").fontWeight(.semibold) } icon: { Image(systemName: "minus.circle") }
                            }
                            .tint(.red)
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

// MARK: - Preview

#Preview {
    let db = PreviewFixtures.prepare()
    let thisWeekMeals = try! PreviewFixtures.seed(into: db).meals.filter { $0.isThisWeek }

    List {
        ThisWeekSection(
            thisWeekMeals: thisWeekMeals,
            hasSeenSwipeHint: .constant(false),
            onRemove: { _ in }
        )
    }
    .listStyle(.insetGrouped)
}
