//
//  Ingredient.swift
//  OurDinner
//
//  Created by Matthew Porter on 2/28/26.
//

import Foundation
import SwiftData

@Model
final class Ingredient {
    var name: String = ""
    var meals: [Meal] = []

    init(name: String) {
        self.name = name
    }
}
