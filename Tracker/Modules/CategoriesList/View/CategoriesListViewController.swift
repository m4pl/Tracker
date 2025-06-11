//
//  CategoriesListViewController.swift
//  Tracker
//
//  Created by mpplokhov on 11.06.2025.
//

import UIKit
import Combine

class CategoriesListViewController: UIViewController {
    
    var selectedСategory: TrackerCategory? = nil
    var onSave: ((TrackerCategory) -> Void)?
    
    private let placeholderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "advice_placeholder_logo")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "Привычки и события можно\nобъединить по смыслу"
        label.textAlignment = .center
        label.textColor = .ypColorBlack
        label.font = AppTextStyle.ypMedium12.font
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
    
    private let tableView: UITableView = {
        let tableView = UITableView(
            frame: .zero,
            style: .insetGrouped
        )
        tableView.backgroundColor = .ypColorWhite
        tableView.allowsMultipleSelection = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Добавить категорию", for: .normal)
        button.backgroundColor = .ypColorBlack
        button.setTitleColor(.ypColorWhite, for: .normal)
        button.titleLabel?.font = AppTextStyle.ypMedium16.font
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let viewModel: CategoriesListViewModel
    private var cancellables = Set<AnyCancellable>()
    
    init(viewModel: CategoriesListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.allCategories
            .receive(on: DispatchQueue.main)
            .sink { [weak self] categories in
                self?.tableView.reloadData()
                self?.updateEmptyState(categories)
            }
            .store(in: &cancellables)

        viewModel.selectedCategoryPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] category in
                self?.onSave?(category)
                self?.dismiss(animated: true, completion: nil)
            }
            .store(in: &cancellables)

        setupUi()
    }
    
    private func updateEmptyState(_ categories: [TrackerCategory]) {
        let isEmpty = categories.isEmpty
        emptyStack.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }
    
    private func setupUi() {
        view.backgroundColor = .ypColorWhite
        setupTableView()
        setupReadyButton()
        setupEmptyPlaceholder()
    }
    
    private func setupReadyButton() {
        addButton.addTarget(
            self,
            action: #selector(addTapped),
            for: .touchUpInside
        )

        view.addSubview(addButton)
        
        NSLayoutConstraint.activate([
            addButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor
            ),
            addButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 20
            ),
            addButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -20
            ),
            addButton.heightAnchor.constraint(
                equalToConstant: 60
            )
        ])
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(
            CategoryCell.self,
            forCellReuseIdentifier: CategoryCell.identifier
        )
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(
                equalTo: view.topAnchor
            ),
            tableView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor
            ),
            tableView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            tableView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
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
    
    @objc private func addTapped() {
    }
}

// MARK: - UITableViewDataSource

extension CategoriesListViewController: UITableViewDataSource {

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return viewModel.allCategories.value.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CategoryCell.identifier,
            for: indexPath
        ) as? CategoryCell else {
            return UITableViewCell()
        }
        
        let category = viewModel.allCategories.value[indexPath.row]
        cell.categoryLabel.text = category.title
        cell.divider.isHidden = (indexPath.row == viewModel.allCategories.value.count - 1)

        if let selected = selectedСategory, selected.title == category.title {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            cell.setSelected(true, animated: false)
        } else {
            cell.setSelected(false, animated: false)
        }

        return cell
    }
}

// MARK: - UITableViewDelegate

extension CategoriesListViewController: UITableViewDelegate {
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        viewModel.selectCategory(at: indexPath.row)
    }

    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return 75
    }
}
