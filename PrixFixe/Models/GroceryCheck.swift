//
//  GroceryCheck.swift
//  PrixFixe
//
//  Created by Matthew Porter on 3/3/26.
//

import Foundation
import SQLiteData

@Table
struct GroceryCheck {
    @Column(primaryKey: true)
    let ingredientID: UUID
}
