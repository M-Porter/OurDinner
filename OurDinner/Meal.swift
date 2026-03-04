//
//  Meal.swift
//  OurDinner
//
//  Created by Matthew Porter on 2/28/26.
//

import Foundation
import SwiftData

@Model
final class Meal {
    @Attribute(.unique) var id: UUID = UUID()
    var name: String = ""
    var isThisWeek: Bool = false
    var ingredientIDs: [String] = []

    init(name: String, isThisWeek: Bool = false) {
        self.id = UUID()
        self.name = name
        self.isThisWeek = isThisWeek
    }
}
