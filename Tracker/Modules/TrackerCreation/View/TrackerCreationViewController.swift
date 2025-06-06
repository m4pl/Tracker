//
//  TrackerCreationViewController.swift
//  Tracker
//
//  Created by mpplokhov on 05.06.2025.
//

import UIKit

final class TrackerCreationViewController: UIViewController {
    
    // MARK: - Properties
    
    var isHabit: Bool = false
    var onTrackerCreated: ((Tracker) -> Void)?
    
    private var schedule: [WeekDay] = []
    
    private let nameField: UITextField = {
        let field = UITextField()
        field.placeholder = "Введите название трекера"
        field.layer.cornerRadius = 16
        field.backgroundColor = .ypColorGray30
        field.leftViewMode = .always
        field.leftView = UIView(
            frame: CGRect(x: 0, y: 0, width: 16, height: 0)
        )
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private func makeRightArrowImageView() -> UIImageView {
        let imageView = UIImageView(
            image: UIImage(systemName: "chevron.right")
        )
        imageView.tintColor = .ypColorGray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }
    
    private let categoryButton = UIButton(type: .system)
    private let scheduleButton = UIButton(type: .system)
    
    private let categoryScheduleContainer: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        view.backgroundColor = .ypColorGray30
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let divider: UIView = {
        let view = UIView()
        view.backgroundColor = .ypColorGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let buttonVerticalStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let cancelButton = UIButton(type: .system)
    private let createButton = UIButton(type: .system)
    
    private let buttonHorizontalStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypColorWhite
        setupGestureToHideKeyboard()
        setupUI()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        setupNameField()
        setupCategoryScheduleStack()
        setupActionButtons()
    }
    
    private func setupGestureToHideKeyboard() {
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(endEditing)
        )
        view.addGestureRecognizer(tap)
    }
    
    private func setupNameField() {
        view.addSubview(nameField)
        NSLayoutConstraint.activate([
            nameField.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 16
            ),
            nameField.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -16
            ),
            nameField.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 24
            ),
            nameField.heightAnchor.constraint(
                equalToConstant: 75
            )
        ])
    }
    
    private func setupCategoryScheduleStack() {
        setupButton(
            categoryButton,
            title: "Категория",
            action: #selector(categoryTapped)
        )
        setupButton(
            scheduleButton,
            title: "Расписание",
            action: #selector(scheduleTapped)
        )
        
        buttonVerticalStack.addArrangedSubview(categoryButton)
        buttonVerticalStack.addArrangedSubview(divider)
        
        if (isHabit) {
            buttonVerticalStack.addArrangedSubview(scheduleButton)
        }
        
        categoryScheduleContainer.addSubview(buttonVerticalStack)
        view.addSubview(categoryScheduleContainer)
        
        NSLayoutConstraint.activate([
            categoryScheduleContainer.topAnchor.constraint(
                equalTo: nameField.bottomAnchor,
                constant: 24
            ),
            categoryScheduleContainer.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 16
            ),
            categoryScheduleContainer.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -16
            ),
            
            buttonVerticalStack.topAnchor.constraint(
                equalTo: categoryScheduleContainer.topAnchor
            ),
            buttonVerticalStack.bottomAnchor.constraint(
                equalTo: categoryScheduleContainer.bottomAnchor
            ),
            buttonVerticalStack.leadingAnchor.constraint(
                equalTo: categoryScheduleContainer.leadingAnchor
            ),
            buttonVerticalStack.trailingAnchor.constraint(
                equalTo: categoryScheduleContainer.trailingAnchor
            ),
            
            divider.heightAnchor.constraint(
                equalToConstant: isHabit ? 1 : 0
            ),
            divider.leadingAnchor.constraint(
                equalTo: buttonVerticalStack.leadingAnchor,
                constant: 16
            ),
            divider.trailingAnchor.constraint(
                equalTo: buttonVerticalStack.trailingAnchor,
                constant: -16
            )
        ])
    }
    
    private func setupButton(
        _ button: UIButton,
        title: String,
        action: Selector
    ) {
        button.setTitle(title, for: .normal)
        button.setTitleColor(.ypColorBlack, for: .normal)
        button.contentHorizontalAlignment = .left
        button.heightAnchor.constraint(equalToConstant: 75).isActive = true
        button.addTarget(self, action: action, for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        let arrow = makeRightArrowImageView()
        
        button.addSubview(arrow)
        
        NSLayoutConstraint.activate([
            arrow.centerYAnchor.constraint(
                equalTo: button.centerYAnchor
            ),
            arrow.trailingAnchor.constraint(
                equalTo: button.trailingAnchor,
                constant: -16
            )
        ])
    }
    
    private func setupActionButtons() {
        setupCancelButton()
        setupCreateButton()
        
        buttonHorizontalStack.addArrangedSubview(cancelButton)
        buttonHorizontalStack.addArrangedSubview(createButton)
        view.addSubview(buttonHorizontalStack)
        
        NSLayoutConstraint.activate([
            buttonHorizontalStack.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 16
            ),
            buttonHorizontalStack.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -16
            ),
            buttonHorizontalStack.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor
            ),
            cancelButton.heightAnchor.constraint(
                equalToConstant: 60
            ),
            createButton.heightAnchor.constraint(
                equalToConstant: 60
            )
        ])
    }
    
    private func setupCancelButton() {
        cancelButton.setTitle("Отменить", for: .normal)
        cancelButton.setTitleColor(.ypColorRed, for: .normal)
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.ypColorRed.cgColor
        cancelButton.layer.cornerRadius = 16
        cancelButton.addTarget(
            self,
            action: #selector(cancelTapped),
            for: .touchUpInside
        )
    }
    
    private func setupCreateButton() {
        createButton.setTitle("Создать", for: .normal)
        createButton.setTitleColor(.ypColorWhite, for: .normal)
        createButton.backgroundColor = .ypColorGray
        createButton.layer.cornerRadius = 16
        createButton.addTarget(
            self,
            action: #selector(createTapped),
            for: .touchUpInside
        )
    }
    
    // MARK: - Actions
    
    @objc private func endEditing() {
        view.endEditing(true)
    }
    
    @objc private func categoryTapped() {}
    
    @objc private func scheduleTapped() {
        let scheduleVC = ScheduleViewController()
        scheduleVC.selectedDays = self.schedule
        scheduleVC.title = "Расписание"
        scheduleVC.onSave = { [weak self] selected in
            self?.schedule = selected
        }
        let navController = UINavigationController(rootViewController: scheduleVC)
        present(navController, animated: true)
    }
    
    @objc private func createTapped() {
        let tracker = Tracker(
            id: UUID(),
            name: nameField.text ?? "",
            color: .systemOrange,
            emoji: "😐",
            schedule: isHabit ? schedule : WeekDay.allCases
        )
        
        onTrackerCreated?(tracker)
        dismiss(animated: true)
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
}
