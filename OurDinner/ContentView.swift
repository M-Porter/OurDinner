//
//  ContentView.swift
//  OurDinner
//
//  Created by Matthew Porter on 2/28/26.
//

import SwiftUI
import SwiftData

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
