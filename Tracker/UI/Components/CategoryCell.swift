//
//  CategoryCell.swift
//  Tracker
//
//  Created by mpplokhov on 11.06.2025.
//

import UIKit

final class CategoryCell: UITableViewCell {
    
    static let identifier = "CategoryCell"
    
    let categoryLabel: UILabel = {
        let label = UILabel()
        label.font = AppTextStyle.ypRegular17.font
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let checkbox: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "selected_category_logo")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let divider: UIView = {
        let view = UIView()
        view.backgroundColor = .ypColorGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(
        style: UITableViewCell.CellStyle,
        reuseIdentifier: String?
    ) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = .ypColorGray30
        selectionStyle = .none
        
        contentView.addSubview(categoryLabel)
        contentView.addSubview(checkbox)
        contentView.addSubview(divider)
        
        NSLayoutConstraint.activate([
            categoryLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 16
            ),
            categoryLabel.centerYAnchor.constraint(
                equalTo: contentView.centerYAnchor
            ),
            
            checkbox.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -16
            ),
            checkbox.centerYAnchor.constraint(
                equalTo: contentView.centerYAnchor
            ),
            
            divider.heightAnchor.constraint(
                equalToConstant: 1
            ),
            divider.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 16
            ),
            divider.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -16
            ),
            divider.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor
            )
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        checkbox.isHidden = !selected
    }
}
