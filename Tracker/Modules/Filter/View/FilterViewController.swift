//
//  FilterViewController.swift
//  Tracker
//
//  Created by mpplokhov on 18.06.2025.
//

import UIKit
final class FilterViewController: UIViewController {

    var selectedFilter: FilterType = .all
    var onFilterSelected: ((FilterType) -> Void)?

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.backgroundColor = .ypColorWhite
        tableView.allowsMultipleSelection = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypColorWhite

        setupTableView()
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
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

extension FilterViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FilterType.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CategoryCell.identifier,
            for: indexPath
        ) as? CategoryCell else {
            return UITableViewCell()
        }

        guard let filter = FilterType(rawValue: indexPath.row) else { return cell }
        cell.categoryLabel.text = filter.title
        cell.divider.isHidden = indexPath.row == FilterType.allCases.count - 1

        if filter == selectedFilter {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            cell.setSelected(true, animated: false)
        } else {
            cell.setSelected(false, animated: false)
        }

        return cell
    }
}

extension FilterViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selected = FilterType(rawValue: indexPath.row)!
        onFilterSelected?(selected)
        dismiss(animated: true)
    }
}
