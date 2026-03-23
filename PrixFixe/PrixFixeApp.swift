//
//  PrixFixeApp.swift
//  PrixFixe
//
//  Created by Matthew Porter on 2/28/26.
//

import SwiftUI
import SQLiteData

@main
struct PrixFixeApp: App {
    init() {
        prepareDependencies {
            $0.defaultDatabase = try! appDatabase()
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
