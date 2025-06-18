//
//  OnboardingContentViewController.swift
//  Tracker
//
//  Created by mpplokhov on 10.06.2025.
//

import UIKit

class OnboardingContentViewController: UIViewController {

    var imageName: String?
    var titleText: String?
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: imageName ?? "")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = titleText
        label.numberOfLines = 0
        label.font = AppTextStyle.ypBold32.font
        label.textAlignment = .center
        label.textColor = .ypColorBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(imageView)
        view.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(
                equalTo: view.topAnchor
            ),
            imageView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor
            ),
            imageView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            imageView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),

            titleLabel.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),
            titleLabel.centerYAnchor.constraint(
                equalTo: view.centerYAnchor
            ),
        ])
    }
}
