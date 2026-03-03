//
//  Item.swift
//  OurDinner
//
//  Created by Matthew Porter on 2/28/26.
//

import Foundation
import SwiftData

@Model
final class Meal {
    var name: String = ""
    var isThisWeek: Bool = false

    init(name: String, isThisWeek: Bool = false) {
        self.name = name
        self.isThisWeek = isThisWeek
    }
}
