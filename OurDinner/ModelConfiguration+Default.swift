//
//  ModelConfiguration+Default.swift
//  OurDinner
//
//  Created by Matthew Porter on 3/3/26.
//

import SwiftData

extension ModelConfiguration {
    /// Returns a `ModelConfiguration` with CloudKit sync explicitly disabled.
    /// Use this everywhere instead of constructing `ModelConfiguration` directly.
    static func appDefault(isStoredInMemoryOnly: Bool = false) -> ModelConfiguration {
        ModelConfiguration(isStoredInMemoryOnly: isStoredInMemoryOnly, cloudKitDatabase: .none)
    }
}
