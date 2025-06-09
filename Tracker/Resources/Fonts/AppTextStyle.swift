//
//  AppTextStyle.swift
//  Tracker
//
//  Created by mpplokhov on 07.06.2025.
//

import UIKit

enum AppTextStyle {
    case ypRegular17
    case ypMedium12
    case ypMedium16
    case ypBold19
    case ypBold32
    case ypBold34

    var font: UIFont {
        switch self {
        case .ypRegular17:
            return UIFont.systemFont(ofSize: 17, weight: .regular)
        case .ypMedium12:
            return UIFont.systemFont(ofSize: 12, weight: .medium)
        case .ypMedium16:
            return UIFont.systemFont(ofSize: 16, weight: .medium)
        case .ypBold19:
            return UIFont.systemFont(ofSize: 19, weight: .bold)
        case .ypBold32:
            return UIFont.systemFont(ofSize: 32, weight: .bold)
        case .ypBold34:
            return UIFont.systemFont(ofSize: 34, weight: .bold)
        }
    }

    var attributes: [NSAttributedString.Key: Any] {
        [
            .font: font
        ]
    }
}
