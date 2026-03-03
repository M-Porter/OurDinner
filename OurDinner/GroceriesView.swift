//
//  GroceriesView.swift
//  OurDinner
//
//  Created by Matthew Porter on 2/28/26.
//

import SwiftUI

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

#Preview {
    GroceriesView()
}
