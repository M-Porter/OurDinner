//
//  ContentView.swift
//  OurDinner
//
//  Created by Matthew Porter on 2/28/26.
//

import SwiftUI
import SwiftData

// MARK: - Root

struct ContentView: View {
    var body: some View {
        TabView {
            MealsView()
                .tabItem {
                    Label("Meals", systemImage: "fork.knife")
                }

            GroceriesView()
                .tabItem {
                    Label("Groceries", systemImage: "cart")
                }
        }
        .tint(.primaryAccent)
    }
}

// MARK: - Meals

struct MealsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Meal.name) private var meals: [Meal]

    @State private var showingAddMeal = false
    @State private var newMealName = ""
    @AppStorage("hasSeenSwipeHint") private var hasSeenSwipeHint = false

    private var thisWeekMeals: [Meal] {
        meals.filter { $0.isThisWeek }
    }

    var body: some View {
        NavigationStack {
            List {
                // This Week section
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

                // All Meals section
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
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Color.listBackground)
            .navigationTitle("Meals")
            .sheet(isPresented: $showingAddMeal) {
                AddMealSheet(isPresented: $showingAddMeal)
            }
        }
    }
}

// MARK: - This Week Toggle Button

struct ThisWeekToggle: View {
    let isThisWeek: Bool
    let action: () -> Void
    var onHintRequest: (() -> Void)? = nil

    var body: some View {
        if isThisWeek {
            Button(action: { onHintRequest?() }) {
                Text("✓ This Week")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.primaryAccent)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.primaryAccent.opacity(0.12))
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        } else {
            Button(action: action) {
                Image(systemName: "plus.circle")
                    .font(.title2)
                    .foregroundStyle(Color.primaryAccent)
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Groceries

struct GroceriesView: View {
    var body: some View {
        NavigationStack {
            Text("Groceries coming soon")
                .foregroundStyle(Color.primaryAccent)
                .font(.headline)
                .navigationTitle("Groceries")
        }
    }
}

// MARK: - Previews

#Preview {
    let container = try! ModelContainer(for: Meal.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    let context = container.mainContext

    let meals: [(String, Bool)] = [
        ("Pasta Carbonara", true),
        ("Tacos", true),
        ("Pizza", false),
        ("Stir Fry", false),
        ("Chicken Soup", false),
        ("Burgers", false),
    ]
    for (name, isThisWeek) in meals {
        context.insert(Meal(name: name, isThisWeek: isThisWeek))
    }

    return ContentView()
        .modelContainer(container)
}
