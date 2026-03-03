//
//  AddMealSheet.swift
//  OurDinner
//
//  Created by Matthew Porter on 2/28/26.
//

import SwiftUI
import SwiftData

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
    }
}

#Preview {
    AddMealSheet(isPresented: .constant(true))
        .modelContainer(for: Meal.self, inMemory: true)
}
