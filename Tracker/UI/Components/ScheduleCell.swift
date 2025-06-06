//
//  ScheduleCell.swift
//  Tracker
//
//  Created by mpplokhov on 05.06.2025.
//

import UIKit

final class ScheduleCell: UITableViewCell {
    
    static let identifier = "ScheduleCell"
    
    let dayLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let toggle: UISwitch = {
        let toggle = UISwitch()
        toggle.onTintColor = .ypColorBlue
        toggle.translatesAutoresizingMaskIntoConstraints = false
        return toggle
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
        
        contentView.addSubview(dayLabel)
        contentView.addSubview(toggle)
        contentView.addSubview(divider)
        
        NSLayoutConstraint.activate([
            dayLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 16
            ),
            dayLabel.centerYAnchor.constraint(
                equalTo: contentView.centerYAnchor
            ),
            
            toggle.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -16
            ),
            toggle.centerYAnchor.constraint(
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
}
