//
//  Color+Palette.swift
//  OurDinner
//
//  Created by Matthew Porter on 2/28/26.
//

import SwiftUI
import UIKit

extension Color {
    static let primaryAccent  = Color(light: Color(hex: "4A7C59"), dark: Color(hex: "7DBF96"))
    static let actionButton   = Color(light: Color(hex: "6B9E78"), dark: Color(hex: "90C67C"))
    static let listBackground = Color(light: Color(hex: "F0F4F1"), dark: Color(hex: "1C2B22"))
    static let rowBackground      = Color(light: .white, dark: Color(hex: "243B2E"))
    static let hintRowBackground  = Color(light: Color(hex: "D6E8DC"), dark: Color(hex: "2E5040"))

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
