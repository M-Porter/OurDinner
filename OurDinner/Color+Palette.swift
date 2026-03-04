//
//  Color+Palette.swift
//  OurDinner
//
//  Created by Matthew Porter on 2/28/26.
//

import SwiftUI
import UIKit

extension Color {
    static let primaryAccent     = Color(light: Color(hex: "006F46"), dark: Color(hex: "4CAF82"))
    static let actionButton      = Color(light: Color(hex: "1A8A5A"), dark: Color(hex: "5DC491"))
    static let listBackground    = Color(light: Color(hex: "F2F5F3"), dark: Color(hex: "006F46"))
    static let rowBackground     = Color(light: .white,               dark: Color(hex: "00593A"))
    static let hintRowBackground = Color(light: Color(hex: "D4EBE0"), dark: Color(hex: "004D32"))

    init(light: Color, dark: Color) {
        self.init(UIColor(dynamicProvider: { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(dark)
                : UIColor(light)
        }))
    }

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
