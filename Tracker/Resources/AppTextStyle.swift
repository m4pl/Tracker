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
    case ypBold34
    
    var font: UIFont {
        switch self {
        case .ypRegular17:
            return UIFont(name: "SFProDisplay-Regular", size: 17)!
        case .ypMedium12:
            return UIFont(name: "SFProDisplay-Medium", size: 12)!
        case .ypMedium16:
            return UIFont(name: "SFProDisplay-Medium", size: 16)!
        case .ypBold19:
            return UIFont(name: "SFProDisplay-Bold", size: 19)!
        case .ypBold34:
            return UIFont(name: "SFProDisplay-Bold", size: 34)!
        }
    }
    
    var attributes: [NSAttributedString.Key: Any] {
        return [
            .font: font,
        ]
    }
}
