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
    @Attribute(.unique) var id: UUID = UUID()
    var name: String = ""

    init(name: String) {
        self.id = UUID()
        self.name = name
    }
}
