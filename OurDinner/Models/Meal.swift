//
//  Meal.swift
//  OurDinner
//
//  Created by Matthew Porter on 2/28/26.
//

import Foundation
import SQLiteData

@Table
struct Meal: Identifiable, Hashable {
    let id: UUID
    var name: String
    var isThisWeek: Bool
    @Column(as: [UUID].JSONRepresentation.self)
    var ingredientIDs: [UUID]
    var createdAt: Date
    var updatedAt: Date

    static func create(name: String, isThisWeek: Bool = false, ingredientIDs: [UUID] = []) -> Meal {
        let now = Date()
        return Meal(id: UUID(), name: name, isThisWeek: isThisWeek, ingredientIDs: ingredientIDs, createdAt: now, updatedAt: now)
    }

    func saving() -> Self {
        var copy = self
        copy.updatedAt = Date()
        return copy
    }
}
