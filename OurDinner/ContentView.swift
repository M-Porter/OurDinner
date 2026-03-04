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
    ContentView()
        .modelContainer(PreviewFixtures.makeContainer())
}
