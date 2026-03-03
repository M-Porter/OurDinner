//
//  Color+Palette.swift
//  OurDinner
//
//  Created by Matthew Porter on 2/28/26.
//

import SwiftUI

extension Color {
    static let primaryAccent     = Color(hex: "4A7C59") // nav tint, tab bar, section headers, toggle
    static let actionButton      = Color(hex: "6B9E78") // add confirm button
    static let listBackground    = Color(hex: "F0F4F1") // whisper sage list background

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8)  & 0xFF) / 255
        let b = Double(int         & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
