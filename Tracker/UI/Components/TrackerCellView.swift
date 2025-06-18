//
//  TrackerCell.swift
//  Tracker
//
//  Created by Matvei Plokhov on 04.06.2025.
//

import UIKit

protocol TrackerCellDelegate: AnyObject {
    func didTapComplete(for cell: TrackerCellView)
}

final class TrackerCellView: UICollectionViewCell {
    
    static let identifier = "TrackerCellView"
    
    weak var delegate: TrackerCellDelegate?
    
    private let backgroundCardView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let backgroundEmojiView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypColorConstantWhite30
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = AppTextStyle.ypMedium16.font
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = BottomAlignedLabel()
        label.font = AppTextStyle.ypMedium12.font
        label.textColor = .ypColorConstantWhite
        label.numberOfLines = 2
        let lineHeight = label.font.lineHeight
        let twoLineHeight = lineHeight * 2
        label.heightAnchor.constraint(equalToConstant: twoLineHeight).isActive = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let daysLabel: UILabel = {
        let label = UILabel()
        label.font = AppTextStyle.ypMedium12.font
        label.textColor = .ypColorBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let completeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.layer.cornerRadius = 17
        button.clipsToBounds = true
        button.tintColor = .ypColorWhite
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var isCompleted = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBackgroundCardView()
        setupBackgroundEmojiView()
        setupEmojiLabel()
        setupNameLabel()
        setupCompleteButton()
        setupDaysLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    
    func configure(with tracker: Tracker, isCompletedToday: Bool, completedDays: Int) {
        let trackerColor = UIColor(hex: tracker.color)
        let localizedDays = String.localizedStringWithFormat(
            NSLocalizedString("days_count", comment: ""), completedDays
        )
        emojiLabel.text = tracker.emoji
        nameLabel.text = tracker.name
        daysLabel.text = localizedDays
        backgroundCardView.backgroundColor = trackerColor
        isCompleted = isCompletedToday
        
        let imageName = isCompleted ? "selected_tracker_logo" : "select_tracker_logo"
        completeButton.setImage(UIImage(named: imageName), for: .normal)
        completeButton.backgroundColor = isCompleted ? trackerColor.withAlphaComponent(0.5) : trackerColor
    }
    
    // MARK: - Private
    
    private func setupBackgroundCardView() {
        contentView.addSubview(backgroundCardView)
        
        NSLayoutConstraint.activate([
            backgroundCardView.topAnchor.constraint(
                equalTo: contentView.topAnchor
            ),
            backgroundCardView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor
            ),
            backgroundCardView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor
            ),
        ])
    }
    
    private func setupBackgroundEmojiView() {
        backgroundCardView.addSubview(backgroundEmojiView)
        
        NSLayoutConstraint.activate([
            backgroundEmojiView.topAnchor.constraint(
                equalTo: backgroundCardView.topAnchor,
                constant: 12
            ),
            backgroundEmojiView.leadingAnchor.constraint(
                equalTo: backgroundCardView.leadingAnchor,
                constant: 12
            ),
            backgroundEmojiView.widthAnchor.constraint(
                equalToConstant: 24
            ),
            backgroundEmojiView.heightAnchor.constraint(
                equalToConstant: 24
            ),
        ])
    }
    
    private func setupEmojiLabel() {
        backgroundEmojiView.addSubview(emojiLabel)
        
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(
                equalTo: backgroundEmojiView.centerXAnchor
            ),
            emojiLabel.centerYAnchor.constraint(
                equalTo: backgroundEmojiView.centerYAnchor
            ),
        ])
    }
    
    private func setupNameLabel() {
        backgroundCardView.addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(
                equalTo: backgroundCardView.leadingAnchor,
                constant: 12
            ),
            nameLabel.topAnchor.constraint(
                equalTo: emojiLabel.bottomAnchor,
                constant: 8
            ),
            nameLabel.trailingAnchor.constraint(
                equalTo: backgroundCardView.trailingAnchor,
                constant: -12
            ),
            nameLabel.bottomAnchor.constraint(
                equalTo: backgroundCardView.bottomAnchor,
                constant: -12
            ),
        ])
    }
    
    private func setupCompleteButton() {
        contentView.addSubview(completeButton)

        completeButton.addTarget(
            self,
            action:#selector(completeButtonTapped),
            for: .touchUpInside
        )

        NSLayoutConstraint.activate([
            completeButton.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -12
            ),
            completeButton.topAnchor.constraint(
                equalTo: backgroundCardView.bottomAnchor,
                constant: 8
            ),
            completeButton.widthAnchor.constraint(
                equalToConstant: 34
            ),
            completeButton.heightAnchor.constraint(
                equalToConstant: 34
            ),
        ])
    }
    
    private func setupDaysLabel() {
        contentView.addSubview(daysLabel)
        
        NSLayoutConstraint.activate([
            daysLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 12
            ),
            daysLabel.trailingAnchor.constraint(
                equalTo: completeButton.leadingAnchor,
                constant: -12
            ),
            daysLabel.centerYAnchor.constraint(
                equalTo: completeButton.centerYAnchor
            ),
        ])
    }
    
    @objc private func completeButtonTapped() {
        delegate?.didTapComplete(for: self)
    }
}
