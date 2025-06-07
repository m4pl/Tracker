//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by mpplokhov on 05.06.2025.
//

import UIKit

final class ScheduleViewController: UIViewController {
    
    // MARK: - Properties
    
    var selectedDays: [WeekDay] = []
    var onSave: (([WeekDay]) -> Void)?
    
    private let tableView: UITableView = {
        let tableView = UITableView(
            frame: .zero,
            style: .insetGrouped
        )
        tableView.backgroundColor = .ypColorWhite
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let readyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Готово", for: .normal)
        button.backgroundColor = .ypColorBlack
        button.setTitleColor(.ypColorWhite, for: .normal)
        button.titleLabel?.font = AppTextStyle.ypMedium16.font
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupReadyButton()
    }
    
    private func setupReadyButton() {
        readyButton.addTarget(
            self,
            action: #selector(doneTapped),
            for: .touchUpInside
        )

        view.addSubview(readyButton)
        
        NSLayoutConstraint.activate([
            readyButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor
            ),
            readyButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 20
            ),
            readyButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -20
            ),
            readyButton.heightAnchor.constraint(
                equalToConstant: 60
            )
        ])
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(
            ScheduleCell.self,
            forCellReuseIdentifier: ScheduleCell.identifier
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
    
    @objc private func doneTapped() {
        onSave?(selectedDays.sorted { $0.rawValue < $1.rawValue })
        dismiss(animated: true)
    }
}

// MARK: - UITableViewDataSource

extension ScheduleViewController: UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return WeekDay.allCases.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ScheduleCell.identifier,
            for: indexPath
        ) as? ScheduleCell else {
            return UITableViewCell()
        }
        
        let day = WeekDay.allCases[indexPath.row]
        cell.dayLabel.text = day.displayName
        cell.toggle.isOn = selectedDays.contains(day)
        cell.toggle.tag = day.rawValue
        cell.toggle.addTarget(
            self,
            action: #selector(switchChanged(_:)),
            for: .valueChanged
        )
        
        cell.divider.isHidden = (indexPath.row == WeekDay.allCases.count - 1)
        
        return cell
    }
    
    @objc private func switchChanged(_ sender: UISwitch) {
        guard let day = WeekDay(rawValue: sender.tag) else { return }
        if sender.isOn {
            if !selectedDays.contains(day) {
                selectedDays.append(day)
            }
        } else {
            selectedDays.removeAll { $0 == day }
        }
    }
}

// MARK: - UITableViewDelegate

extension ScheduleViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return 75
    }
}
