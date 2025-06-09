//
//  BottomAlignedLabel.swift
//  Tracker
//
//  Created by Matvei Plokhov on 04.06.2025.
//

import UIKit

final class BottomAlignedLabel: UILabel {

    override func drawText(in rect: CGRect) {
        let textRect = textRect(forBounds: rect, limitedToNumberOfLines: numberOfLines)
        let offsetY = rect.height - textRect.height
        let newRect = CGRect(x: rect.origin.x, y: rect.origin.y + offsetY, width: rect.width, height: textRect.height)
        
        super.drawText(in: newRect)
    }
}
