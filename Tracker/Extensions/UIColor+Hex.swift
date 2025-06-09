//
//  UIColor+Hex.swift
//  Tracker
//
//  Created by mpplokhov on 08.06.2025.
//

import UIKit

extension UIColor {
    func toHex() -> String {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        let rgb = (Int)(red * 255)<<24 | (Int)(green * 255)<<16 | (Int)(blue * 255)<<8 | (Int)(alpha * 255)
        return String(format: "#%08X", rgb)
    }

    convenience init(hex: String) {
        var hexFormatted = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        hexFormatted = hexFormatted.replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgb)
        let r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
        let g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
        let b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
        let a = CGFloat(rgb & 0x000000FF) / 255.0
        self.init(red: r, green: g, blue: b, alpha: a)
    }
}
