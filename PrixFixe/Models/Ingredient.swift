//
//  Ingredient.swift
//  PrixFixe
//
//  Created by Matthew Porter on 2/28/26.
//

import Foundation
import SQLiteData

@Table
struct Ingredient: Identifiable {
    let id: UUID
    var name: String
    var createdAt: Date
    var updatedAt: Date

    static func create(name: String) -> Ingredient {
        let now = Date()
        return Ingredient(id: UUID(), name: name, createdAt: now, updatedAt: now)
    }

    func saving() -> Self {
        var copy = self
        copy.updatedAt = Date()
        return copy
    }
}
