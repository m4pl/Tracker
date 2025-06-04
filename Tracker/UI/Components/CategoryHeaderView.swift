//
//  CategoryHeaderView.swift
//  Tracker
//
//  Created by Matvei Plokhov on 04.06.2025.
//

import UIKit

final class CategoryHeaderView: UICollectionReusableView {
    
    static let identifier = "CategoryHeaderView"
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        label.textColor = .ypColorBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTitleLabel()
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: topAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupTitleLabel() {
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: 12
            ),
            titleLabel.bottomAnchor.constraint(
                equalTo: bottomAnchor,
                constant: -12
            ),
            titleLabel.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -12
            ),
            titleLabel.topAnchor.constraint(
                equalTo: topAnchor,
                constant: 16
            ),
        ])
    }
    
    func configure(with title: String) {
        titleLabel.text = title
    }
}
