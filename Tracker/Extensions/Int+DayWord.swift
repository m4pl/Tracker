//
//  Int+DayWord.swift
//  Tracker
//
//  Created by Matvei Plokhov on 04.06.2025.
//

import Foundation

extension Int {
    var dayWord: String {
        let rem100 = self % 100
        let rem10 = self % 10
        
        if rem100 >= 11 && rem100 <= 14 {
            return "дней"
        }
        
        return switch rem10 {
        case 1: "день"
        case 2...4: "дня"
        default: "дней"
        }
    }
}
