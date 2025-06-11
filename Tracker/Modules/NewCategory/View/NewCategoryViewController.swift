//
//  NewCategoryViewController.swift
//  Tracker
//
//  Created by mpplokhov on 11.06.2025.
//

import UIKit

final class NewCategoryViewController: UIViewController {
    
    private let nameField: UITextField = {
        let field = UITextField()
        field.placeholder = "Введите название категории"
        field.layer.cornerRadius = 16
        field.backgroundColor = .ypColorGray30
        field.leftViewMode = .always
        field.leftView = UIView(
            frame: CGRect(x: 0, y: 0, width: 16, height: 0)
        )
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private let createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Готово", for: .normal)
        button.backgroundColor = .ypColorBlack
        button.setTitleColor(.ypColorWhite, for: .normal)
        button.titleLabel?.font = AppTextStyle.ypMedium16.font
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let viewModel: NewCategoryViewModel
    
    init(viewModel: NewCategoryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGestureToHideKeyboard()
        setupUI()
        updateCreateButtonState()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .ypColorWhite

        view.addSubview(nameField)
        view.addSubview(createButton)
        
        nameField.addTarget(
            self,
            action: #selector(nameChanged),
            for: .editingChanged
        )
        createButton.addTarget(
            self,
            action: #selector(createTapped),
            for: .touchUpInside
        )
        
        NSLayoutConstraint.activate([
            nameField.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 24
            ),
            nameField.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 16
            ),
            nameField.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -16
            ),
            nameField.heightAnchor.constraint(
                equalToConstant: 75
            ),
            
            createButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -16
            ),
            createButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 20
            ),
            createButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -20
            ),
            createButton.heightAnchor.constraint(
                equalToConstant: 60
            )
        ])
    }
    
    private func setupGestureToHideKeyboard() {
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(endEditing)
        )
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    private func updateCreateButtonState() {
        let isReady = !(nameField.text?.isEmpty ?? true)
        
        createButton.isEnabled = isReady
        createButton.backgroundColor = isReady ? .ypColorBlack : .ypColorGray
    }
    
    // MARK: - Actions
    
    @objc private func endEditing() {
        view.endEditing(true)
    }
    
    @objc private func nameChanged() {
        updateCreateButtonState()
    }
    
    @objc private func createTapped() {
        guard let categoryName = nameField.text else {
            return
        }
        
        viewModel.createCategory(categoryName)
        dismiss(animated: true)
    }
}
