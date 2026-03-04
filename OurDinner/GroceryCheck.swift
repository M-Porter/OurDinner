//
//  GroceryCheck.swift
//  OurDinner
//
//  Created by Matthew Porter on 3/3/26.
//

import Foundation
import SwiftData

@Model
final class GroceryCheck {
    @Attribute(.unique) var ingredientID: String = ""

    init(ingredientID: String) {
        self.ingredientID = ingredientID
    }
}
