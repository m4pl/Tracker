//
//  StatisticCell.swift
//  Tracker
//
//  Created by mpplokhov on 19.06.2025.
//

import UIKit

final class StatisticCell: UITableViewCell {
    
    static let identifier = "StatisticCell"
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = AppTextStyle.ypBold34.font
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = AppTextStyle.ypMedium12.font
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let gradientBorderLayer = CAGradientLayer()
    private let borderMaskLayer = CAShapeLayer()
    
    override init(
        style: UITableViewCell.CellStyle,
        reuseIdentifier: String?
    ) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = .ypColorWhite
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        selectionStyle = .none
        
        backgroundColor = .clear
        contentView.backgroundColor = .ypColorWhite
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 12
            ),
            titleLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -12
            ),
            titleLabel.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: 12
            ),
            
            subtitleLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 12
            ),
            subtitleLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -12
            ),
            subtitleLabel.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor,
                constant: 8
            ),
            subtitleLabel.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -12
            ),
        ])
        
        setupGradientBorder()
    }
    
    private func setupGradientBorder() {
        gradientBorderLayer.colors = [
            UIColor(hex: "#007BFAFF").cgColor,
            UIColor(hex: "#46E69DFF").cgColor,
            UIColor(hex: "#FD4C49FF").cgColor
        ]
        gradientBorderLayer.startPoint = CGPoint(x: 1, y: 0.5)
        gradientBorderLayer.endPoint = CGPoint(x: 0, y: 0.5)
        gradientBorderLayer.frame = contentView.bounds
        gradientBorderLayer.cornerRadius = 16
        
        borderMaskLayer.path = UIBezierPath(roundedRect: contentView.bounds.insetBy(dx: 0.5, dy: 0.5), cornerRadius: 16).cgPath
        borderMaskLayer.lineWidth = 1
        borderMaskLayer.fillColor = UIColor.clear.cgColor
        borderMaskLayer.strokeColor = UIColor.black.cgColor
        
        gradientBorderLayer.mask = borderMaskLayer
        
        contentView.layer.insertSublayer(gradientBorderLayer, at: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientBorderLayer.frame = contentView.bounds
        borderMaskLayer.path = UIBezierPath(roundedRect: contentView.bounds.insetBy(dx: 0.5, dy: 0.5), cornerRadius: 16).cgPath
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
