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
                                    meal.isThisWeek.toggle()
                                }
                            }
                        }
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
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddMeal = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundStyle(Color.primaryAccent)
                    }
                }
            }
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
        Button(action: action) {
            Image(systemName: isThisWeek ? "checkmark.circle.fill" : "circle")
                .font(.title2)
                .foregroundStyle(Color.primaryAccent)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Add Meal Sheet

struct AddMealSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var isPresented: Bool
    @State private var name = ""
    @FocusState private var fieldFocused: Bool

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Meal name", text: $name)
                        .focused($fieldFocused)
                } header: {
                    Text("New Meal")
                        .foregroundStyle(Color.primaryAccent)
                        .textCase(nil)
                }
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
                        let trimmed = name.trimmingCharacters(in: .whitespaces)
                        guard !trimmed.isEmpty else { return }
                        modelContext.insert(Meal(name: trimmed))
                        isPresented = false
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(name.trimmingCharacters(in: .whitespaces).isEmpty
                                     ? Color.secondary
                                     : Color.actionButton)
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear { fieldFocused = true }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
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
