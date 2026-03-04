//
//  PreviewFixtures.swift
//  OurDinner
//
//  Created by Matthew Porter on 3/3/26.
//

#if DEBUG
import SwiftUI
import SwiftData

struct PreviewFixtures {
    /// Creates an in-memory ModelContainer seeded with realistic fixture data.
    static func makeContainer() -> ModelContainer {
        let container = try! ModelContainer(
            for: Meal.self, Ingredient.self, GroceryCheck.self,
            configurations: ModelConfiguration.appDefault(isStoredInMemoryOnly: true)
        )
        seed(into: container.mainContext)
        return container
    }

    /// Seeds all fixture ingredients and meals into the given context.
    @discardableResult
    static func seed(into context: ModelContext) -> (meals: [Meal], ingredients: [Ingredient]) {
        // MARK: Ingredients
        let pasta = Ingredient(name: "Pasta")
        let eggs = Ingredient(name: "Eggs")
        let parmesan = Ingredient(name: "Parmesan")
        let pancetta = Ingredient(name: "Pancetta")
        let chicken = Ingredient(name: "Chicken")
        let lime = Ingredient(name: "Lime")
        let tortillas = Ingredient(name: "Tortillas")
        let beef = Ingredient(name: "Beef")
        let garlic = Ingredient(name: "Garlic")
        let mozzarella = Ingredient(name: "Mozzarella")
        let tomato = Ingredient(name: "Tomato")
        let soy = Ingredient(name: "Soy Sauce")
        let ginger = Ingredient(name: "Ginger")
        let broth = Ingredient(name: "Chicken Broth")
        let buns = Ingredient(name: "Buns")

        let ingredients = [pasta, eggs, parmesan, pancetta, chicken, lime,
                           tortillas, beef, garlic, mozzarella, tomato,
                           soy, ginger, broth, buns]
        ingredients.forEach { context.insert($0) }

        // MARK: Meals
        let carbonara = Meal(name: "Pasta Carbonara", isThisWeek: true)
        carbonara.ingredientIDs = [pasta, eggs, parmesan, pancetta, garlic].map { $0.id.uuidString }

        let tacos = Meal(name: "Tacos", isThisWeek: true)
        tacos.ingredientIDs = [chicken, lime, tortillas, garlic].map { $0.id.uuidString }

        let pizza = Meal(name: "Pizza", isThisWeek: false)
        pizza.ingredientIDs = [mozzarella, tomato, garlic].map { $0.id.uuidString }

        let stirFry = Meal(name: "Stir Fry", isThisWeek: false)
        stirFry.ingredientIDs = [chicken, soy, ginger, garlic].map { $0.id.uuidString }

        let chickenSoup = Meal(name: "Chicken Soup", isThisWeek: false)
        chickenSoup.ingredientIDs = [chicken, broth, garlic].map { $0.id.uuidString }

        let burgers = Meal(name: "Burgers", isThisWeek: false)
        burgers.ingredientIDs = [beef, buns, tomato].map { $0.id.uuidString }

        let meals = [carbonara, tacos, pizza, stirFry, chickenSoup, burgers]
        meals.forEach { context.insert($0) }

        return (meals: meals, ingredients: ingredients)
    }
}
#endif
