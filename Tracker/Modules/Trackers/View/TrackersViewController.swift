//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Matvei Plokhov on 04.06.2025.
//

import UIKit

final class TrackersViewController: UIViewController {
    
    private let titleLabel: UILabel = {
       let label = UILabel()
        label.text = "Трекеры"
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.textColor = .ypColorBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let placeholderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "advice_placeholder_logo")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.textAlignment = .center
        label.textColor = .ypColorBlack
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emptyStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private var categories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUi()
    }
    
    private func setupUi() {
        view.backgroundColor = .ypColorWhite
        setupNavigationBar()
        setupTitleLabel()
        setupEmptyPlaceholder()
    }

    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "add_tracker_logo"),
            style: .plain,
            target: self,
            action: #selector(addTracker)
        )
        navigationItem.leftBarButtonItem?.tintColor = .ypColorBlack
    }

    private func setupTitleLabel() {
        view.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 1
            ),
            titleLabel.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 16
            ),
            titleLabel.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -16
            )
        ])
    }

    private func setupEmptyPlaceholder() {
        emptyStack.addArrangedSubview(placeholderImageView)
        emptyStack.addArrangedSubview(emptyLabel)
        view.addSubview(emptyStack)

        NSLayoutConstraint.activate([
            placeholderImageView.widthAnchor.constraint(
                equalToConstant: 80
            ),
            placeholderImageView.heightAnchor.constraint(
                equalToConstant: 80
            ),

            emptyLabel.leadingAnchor.constraint(
                equalTo: emptyStack.leadingAnchor
            ),
            emptyLabel.trailingAnchor.constraint(
                equalTo: emptyStack.trailingAnchor
            ),

            emptyStack.centerYAnchor.constraint(
                equalTo: view.centerYAnchor
            ),
            emptyStack.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 16
            ),
            emptyStack.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -16
            )
        ])
    }
    
    @objc private func addTracker() {
    }
}
