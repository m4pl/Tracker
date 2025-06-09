//
//  TrackerTypeSelectionViewController.swift
//  Tracker
//
//  Created by mpplokhov on 05.06.2025.
//

import UIKit

final class TrackerTypeSelectionViewController: UIViewController {
    
    var onTypeSelected: ((Bool) -> Void)?
    
    private let habitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Привычка", for: .normal)
        button.backgroundColor = .ypColorBlack
        button.setTitleColor(.ypColorWhite, for: .normal)
        button.titleLabel?.font = AppTextStyle.ypMedium16.font
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let eventButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Нерегулярное событие", for: .normal)
        button.backgroundColor = .ypColorBlack
        button.setTitleColor(.ypColorWhite, for: .normal)
        button.titleLabel?.font = AppTextStyle.ypMedium16.font
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let buttonStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUi()
    }
    
    private func setupUi() {
        view.backgroundColor = .ypColorWhite
        setupButtonStack()
        setupHabitButton()
        setupEventButton()
    }
    
    private func setupButtonStack() {
        buttonStack.addArrangedSubview(habitButton)
        buttonStack.addArrangedSubview(eventButton)
        view.addSubview(buttonStack)
        
        NSLayoutConstraint.activate([
            buttonStack.centerYAnchor.constraint(
                equalTo: view.centerYAnchor
            ),
            buttonStack.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 20
            ),
            buttonStack.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -20
            )
        ])
    }
    
    private func setupHabitButton() {
        habitButton.addTarget(
            self,
            action: #selector(habitSelected),
            for: .touchUpInside
        )
        
        NSLayoutConstraint.activate([
            habitButton.leadingAnchor.constraint(
                equalTo: buttonStack.leadingAnchor
            ),
            habitButton.trailingAnchor.constraint(
                equalTo: buttonStack.trailingAnchor
            ),
            habitButton.heightAnchor.constraint(
                equalToConstant: 60
            ),
        ])
    }
    
    private func setupEventButton() {
        eventButton.addTarget(
            self,
            action: #selector(eventSelected),
            for: .touchUpInside
        )
        
        NSLayoutConstraint.activate([
            eventButton.leadingAnchor.constraint(
                equalTo: buttonStack.leadingAnchor
            ),
            eventButton.trailingAnchor.constraint(
                equalTo: buttonStack.trailingAnchor
            ),
            eventButton.heightAnchor.constraint(
                equalToConstant: 60
            ),
        ])
    }
    
    @objc private func habitSelected() {
        dismiss(animated: true) {
            self.onTypeSelected?(true)
        }
    }
    
    @objc private func eventSelected() {
        dismiss(animated: true) {
            self.onTypeSelected?(false)
        }
    }
}
