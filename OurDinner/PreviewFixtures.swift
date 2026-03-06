//
//  PreviewFixtures.swift
//  OurDinner
//
//  Created by Matthew Porter on 3/3/26.
//

#if DEBUG
import Foundation
import SQLiteData

struct PreviewFixtures {
    static func prepare() -> any DatabaseWriter {
        let db = try! makeDatabase()
        prepareDependencies {
            $0.defaultDatabase = db
        }
        return db
    }
    
    /// Creates an in-memory database seeded with realistic fixture data.
    static func makeDatabase() throws -> any DatabaseWriter {
        let database = try DatabaseQueue()
        try prepareDatabaseSchema(database)
        try seed(into: database)
        return database
    }

    /// Runs the full migration schema against an arbitrary DatabaseWriter.
    static func prepareDatabaseSchema(_ database: any DatabaseWriter) throws {
        var migrator = DatabaseMigrator()
        migrator.registerMigrations()
        try migrator.migrate(database)
    }

    /// Seeds all fixture ingredients and meals into the given database.
    @discardableResult
    static func seed(into database: any DatabaseWriter) throws -> (meals: [Meal], ingredients: [Ingredient]) {
        // Truncate DB so we don't have double data
        try database.write { db in
            try Meal.delete().execute(db)
            try Ingredient.delete().execute(db)
            try GroceryCheck.delete().execute(db)
        }

        // MARK: Ingredients
        let now = Date()
        let pasta       = Ingredient(id: UUID(), name: "Pasta",         createdAt: now, updatedAt: now)
        let eggs        = Ingredient(id: UUID(), name: "Eggs",          createdAt: now, updatedAt: now)
        let parmesan    = Ingredient(id: UUID(), name: "Parmesan",      createdAt: now, updatedAt: now)
        let pancetta    = Ingredient(id: UUID(), name: "Pancetta",      createdAt: now, updatedAt: now)
        let chicken     = Ingredient(id: UUID(), name: "Chicken",       createdAt: now, updatedAt: now)
        let lime        = Ingredient(id: UUID(), name: "Lime",          createdAt: now, updatedAt: now)
        let tortillas   = Ingredient(id: UUID(), name: "Tortillas",     createdAt: now, updatedAt: now)
        let beef        = Ingredient(id: UUID(), name: "Beef",          createdAt: now, updatedAt: now)
        let garlic      = Ingredient(id: UUID(), name: "Garlic",        createdAt: now, updatedAt: now)
        let mozzarella  = Ingredient(id: UUID(), name: "Mozzarella",    createdAt: now, updatedAt: now)
        let tomato      = Ingredient(id: UUID(), name: "Tomato",        createdAt: now, updatedAt: now)
        let soy         = Ingredient(id: UUID(), name: "Soy Sauce",     createdAt: now, updatedAt: now)
        let ginger      = Ingredient(id: UUID(), name: "Ginger",        createdAt: now, updatedAt: now)
        let broth       = Ingredient(id: UUID(), name: "Chicken Broth", createdAt: now, updatedAt: now)
        let buns        = Ingredient(id: UUID(), name: "Buns",          createdAt: now, updatedAt: now)

        let ingredients = [pasta, eggs, parmesan, pancetta, chicken, lime,
                           tortillas, beef, garlic, mozzarella, tomato,
                           soy, ginger, broth, buns]

        // MARK: Meals
        let carbonara = Meal(
            id: UUID(), name: "Pasta Carbonara", isThisWeek: true,
            ingredientIDs: [pasta, eggs, parmesan, pancetta, garlic].map(\.id),
            createdAt: now, updatedAt: now
        )
        let tacos = Meal(
            id: UUID(), name: "Tacos", isThisWeek: true,
            ingredientIDs: [chicken, lime, tortillas, garlic].map(\.id),
            createdAt: now, updatedAt: now
        )
        let pizza = Meal(
            id: UUID(), name: "Pizza", isThisWeek: false,
            ingredientIDs: [mozzarella, tomato, garlic].map(\.id),
            createdAt: now, updatedAt: now
        )
        let stirFry = Meal(
            id: UUID(), name: "Stir Fry", isThisWeek: false,
            ingredientIDs: [chicken, soy, ginger, garlic].map(\.id),
            createdAt: now, updatedAt: now
        )
        let chickenSoup = Meal(
            id: UUID(), name: "Chicken Soup", isThisWeek: false,
            ingredientIDs: [chicken, broth, garlic].map(\.id),
            createdAt: now, updatedAt: now
        )
        let burgers = Meal(
            id: UUID(), name: "Burgers", isThisWeek: false,
            ingredientIDs: [beef, buns, tomato].map(\.id),
            createdAt: now, updatedAt: now
        )

        let meals = [carbonara, tacos, pizza, stirFry, chickenSoup, burgers]

        try database.write { db in
            try db.seed {
                for ingredient in ingredients { ingredient }
                for meal in meals { meal }
            }
        }

        return (meals: meals, ingredients: ingredients)
    }
}
#endif
