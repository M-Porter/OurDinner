//
//  Ingredient.swift
//  OurDinner
//
//  Created by Matthew Porter on 2/28/26.
//

import Foundation
import SQLiteData

@Table
struct Ingredient: Identifiable {
    let id: UUID
    var name: String
}
