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
}
