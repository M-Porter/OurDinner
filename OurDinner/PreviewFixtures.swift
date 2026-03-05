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
        migrator.registerMigration("v1") { db in
            try #sql("""
                CREATE TABLE "meals" (
                  "id"            TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
                  "name"          TEXT NOT NULL,
                  "isThisWeek"    INTEGER NOT NULL DEFAULT 0,
                  "ingredientIDs" TEXT NOT NULL DEFAULT '[]'
                ) STRICT
                """).execute(db)

            try #sql("""
                CREATE TABLE "ingredients" (
                  "id"   TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
                  "name" TEXT NOT NULL
                ) STRICT
                """).execute(db)

            try #sql("""
                CREATE TABLE "groceryChecks" (
                  "ingredientID" TEXT PRIMARY KEY NOT NULL
                ) STRICT
                """).execute(db)
        }
        try migrator.migrate(database)
    }

    /// Seeds all fixture ingredients and meals into the given database.
    @discardableResult
    static func seed(into database: any DatabaseWriter) throws -> (meals: [Meal], ingredients: [Ingredient]) {
        // MARK: Ingredients
        let pasta       = Ingredient(id: UUID(), name: "Pasta")
        let eggs        = Ingredient(id: UUID(), name: "Eggs")
        let parmesan    = Ingredient(id: UUID(), name: "Parmesan")
        let pancetta    = Ingredient(id: UUID(), name: "Pancetta")
        let chicken     = Ingredient(id: UUID(), name: "Chicken")
        let lime        = Ingredient(id: UUID(), name: "Lime")
        let tortillas   = Ingredient(id: UUID(), name: "Tortillas")
        let beef        = Ingredient(id: UUID(), name: "Beef")
        let garlic      = Ingredient(id: UUID(), name: "Garlic")
        let mozzarella  = Ingredient(id: UUID(), name: "Mozzarella")
        let tomato      = Ingredient(id: UUID(), name: "Tomato")
        let soy         = Ingredient(id: UUID(), name: "Soy Sauce")
        let ginger      = Ingredient(id: UUID(), name: "Ginger")
        let broth       = Ingredient(id: UUID(), name: "Chicken Broth")
        let buns        = Ingredient(id: UUID(), name: "Buns")

        let ingredients = [pasta, eggs, parmesan, pancetta, chicken, lime,
                           tortillas, beef, garlic, mozzarella, tomato,
                           soy, ginger, broth, buns]

        // MARK: Meals
        let carbonara = Meal(
            id: UUID(), name: "Pasta Carbonara", isThisWeek: true,
            ingredientIDs: [pasta, eggs, parmesan, pancetta, garlic].map(\.id)
        )
        let tacos = Meal(
            id: UUID(), name: "Tacos", isThisWeek: true,
            ingredientIDs: [chicken, lime, tortillas, garlic].map(\.id)
        )
        let pizza = Meal(
            id: UUID(), name: "Pizza", isThisWeek: false,
            ingredientIDs: [mozzarella, tomato, garlic].map(\.id)
        )
        let stirFry = Meal(
            id: UUID(), name: "Stir Fry", isThisWeek: false,
            ingredientIDs: [chicken, soy, ginger, garlic].map(\.id)
        )
        let chickenSoup = Meal(
            id: UUID(), name: "Chicken Soup", isThisWeek: false,
            ingredientIDs: [chicken, broth, garlic].map(\.id)
        )
        let burgers = Meal(
            id: UUID(), name: "Burgers", isThisWeek: false,
            ingredientIDs: [beef, buns, tomato].map(\.id)
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
