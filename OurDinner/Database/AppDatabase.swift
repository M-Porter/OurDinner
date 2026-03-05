//
//  AppDatabase.swift
//  OurDinner
//
//  Created by Matthew Porter on 2/28/26.
//

import SQLiteData

func appDatabase() throws -> any DatabaseWriter {
    @Dependency(\.context) var context
    let configuration = Configuration()
    let database = try defaultDatabase(configuration: configuration)

    var migrator = DatabaseMigrator()
    #if DEBUG
    migrator.eraseDatabaseOnSchemaChange = true
    #endif

    migrator.registerMigrations()
    
    try migrator.migrate(database)
    return database
}

extension DatabaseMigrator {
    mutating func registerMigrations() {
        registerV1Migration()
    }

    mutating private func registerV1Migration() {
        registerMigration("v1") { db in
            try #sql("""
                CREATE TABLE "meals" (
                  "id"            TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
                  "name"          TEXT NOT NULL,
                  "isThisWeek"    INTEGER NOT NULL DEFAULT 0,
                  "ingredientIDs" TEXT NOT NULL DEFAULT '[]',
                  "createdAt"     TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
                  "updatedAt"     TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))
                ) STRICT
                """).execute(db)

            try #sql("""
                CREATE TABLE "ingredients" (
                  "id"        TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
                  "name"      TEXT NOT NULL,
                  "createdAt" TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
                  "updatedAt" TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))
                ) STRICT
                """).execute(db)

            try #sql("""
                CREATE TABLE "groceryChecks" (
                  "ingredientID" TEXT PRIMARY KEY NOT NULL
                ) STRICT
                """).execute(db)
        }
    }
}
