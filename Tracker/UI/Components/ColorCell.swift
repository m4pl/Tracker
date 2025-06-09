//
//  ColorCell.swift
//  Tracker
//
//  Created by mpplokhov on 08.06.2025.
//

import UIKit

final class ColorCell: UICollectionViewCell {
    
    static let identifier = "ColorCell"

    private let colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var currentColor: UIColor = .clear

    override var isSelected: Bool {
        didSet {
            layer.borderWidth = isSelected ? 3 : 0
            layer.borderColor = isSelected ? currentColor.withAlphaComponent(0.3).cgColor : nil
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(colorView)
        contentView.clipsToBounds = false

        layer.cornerRadius = 12
        layer.masksToBounds = true

        NSLayoutConstraint.activate([
            colorView.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: 6
            ),
            colorView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -6
            ),
            colorView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 6
            ),
            colorView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -6
            )
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with color: UIColor) {
        currentColor = color
        colorView.backgroundColor = color
    }
}
