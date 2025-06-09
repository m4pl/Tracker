//
//  EmojiCell.swift
//  Tracker
//
//  Created by mpplokhov on 08.06.2025.
//

import UIKit

final class EmojiCell: UICollectionViewCell {
    
    static let identifier = "EmojiCell"
    
    private let label: UILabel = {
        let label = UILabel()
        label.font = AppTextStyle.ypBold32.font
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override var isSelected: Bool {
        didSet {
            contentView.backgroundColor = isSelected ? UIColor.ypColorLightGray : .clear
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(label)
        contentView.layer.cornerRadius = 16
        contentView.clipsToBounds = true

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with emoji: String) {
        label.text = emoji
    }
}
