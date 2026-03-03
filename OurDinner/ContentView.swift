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
                    } else {
                        ForEach(thisWeekMeals) { meal in
                            Text(meal.name)
                                .font(.body)
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        withAnimation {
                                            meal.isThisWeek = false
                                        }
                                    } label: {
                                        Label("Remove", systemImage: "minus.circle")
                                    }
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
                            }
                        }
                    }
                    Button {
                        showingAddMeal = true
                    } label: {
                        Label("Add meal...", systemImage: "plus.circle.fill")
                            .foregroundStyle(Color.primaryAccent)
                    }
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

    var body: some View {
        if isThisWeek {
            Text("✓ This Week")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(Color.primaryAccent)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.primaryAccent.opacity(0.12))
                .clipShape(Capsule())
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
