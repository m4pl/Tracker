//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Matvei Plokhov on 04.06.2025.
//

import UIKit
import Combine

final class TrackersViewController: UIViewController, UICollectionViewDelegate {
    
    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.maximumDate = Date()
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    private let placeholderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .advicePlaceholderLogo)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("tracking_prompt", comment: "")
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
    
    private lazy var flowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 9
        layout.minimumLineSpacing = 0
        return layout
    }()
    
    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        return view
    }()
    
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = NSLocalizedString("search", comment: "")
        searchController.searchResultsUpdater = self
        return searchController
    }()
    
    private let viewModel: TrackersViewModel
    private var cancellables = Set<AnyCancellable>()
    
    init(viewModel: TrackersViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.visibleCategories
            .receive(on: DispatchQueue.main)
            .sink { [weak self] categories in
                self?.collectionView.reloadData()
                self?.updateEmptyState(categories)
            }
            .store(in: &cancellables)

        viewModel.$searchText
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.viewModel.filterVisibleCategories()
            }
            .store(in: &cancellables)

        setupUi()
    }
    
    private func updateEmptyState(_ categories: [TrackerCategory]) {
        let isEmpty = categories.isEmpty
        emptyStack.isHidden = !isEmpty
        collectionView.isHidden = isEmpty
    }
    
    private func setupUi() {
        view.backgroundColor = .ypColorWhite
        setupNavigationBar()
        setupCollectionView()
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
        datePicker.addTarget(
            self,
            action: #selector(dateChanged(_:)),
            for: .valueChanged
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            customView: datePicker
        )
        navigationItem.title = NSLocalizedString("trackers", comment: "")
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.searchController = searchController
        definesPresentationContext = true
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
    
    private func setupCollectionView() {
        let availableWidth = view.bounds.width - 32 - flowLayout.minimumInteritemSpacing
        let cellWidth = floor(availableWidth / 2)
        flowLayout.itemSize = CGSize(width: cellWidth, height: 148)
        
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(
            TrackerCellView.self,
            forCellWithReuseIdentifier: TrackerCellView.identifier
        )
        collectionView.register(
            CategoryHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: CategoryHeaderView.identifier
        )
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 8
            ),
            collectionView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 16
            ),
            collectionView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -16
            ),
            collectionView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor
            )
        ])
    }
    
    private func tracker(at indexPath: IndexPath) -> Tracker {
        return viewModel.visibleCategories.value[indexPath.section].trackers[indexPath.item]
    }
    
    private func category(at section: Int) -> TrackerCategory {
        return viewModel.visibleCategories.value[section]
    }
    
    @objc private func dateChanged(_ sender: UIDatePicker) {
        viewModel.selectedDate = sender.date
    }
    
    @objc private func addTracker() {
        let typeVC = TrackerTypeSelectionViewController()
        typeVC.title = NSLocalizedString("tracker_creation_title", comment: "")
        typeVC.onTypeSelected = { [weak self] isHabit in
            self?.presentTrackerCreation(isHabit: isHabit)
        }
        let navController = UINavigationController(rootViewController: typeVC)
        navController.navigationBar.titleTextAttributes = AppTextStyle.ypMedium16.attributes
        present(navController, animated: true)
    }
    
    private func presentTrackerCreation(isHabit: Bool) {
        let creationVC = TrackerCreationViewController()
        creationVC.isHabit = isHabit
        creationVC.title = isHabit ? NSLocalizedString("new_habit_title", comment: "") : NSLocalizedString("new_event_title", comment: "")
        creationVC.onTrackerCreated = { [weak self] tracker, category in
            self?.viewModel.addTracker(tracker, category)
        }
        let navController = UINavigationController(rootViewController: creationVC)
        navController.navigationBar.titleTextAttributes = AppTextStyle.ypMedium16.attributes
        present(navController, animated: true)
    }
}

extension TrackersViewController: UICollectionViewDataSource {
    
    func numberOfSections(
        in collectionView: UICollectionView
    ) -> Int {
        viewModel.visibleCategories.value.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        category(at: section).trackers.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCellView.identifier,
            for: indexPath
        ) as? TrackerCellView else {
            return UICollectionViewCell()
        }
        
        let tracker = tracker(at: indexPath)
        cell.configure(
            with: tracker,
            isCompletedToday: viewModel.isTrackerCompletedToday(tracker.id),
            completedDays: viewModel.completedDaysCount(for: tracker.id)
        )
        cell.delegate = self
        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: CategoryHeaderView.identifier,
            for: indexPath
        ) as? CategoryHeaderView else {
            return UICollectionReusableView()
        }
        
        let category = category(at: indexPath.section)
        header.configure(with: category.title)
        return header
    }
}

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 46)
    }
}

extension TrackersViewController: TrackerCellDelegate {
    func didTapComplete(for cell: TrackerCellView) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let tracker = tracker(at: indexPath)
        viewModel.toggleTrackerCompletion(tracker.id)
        collectionView.reloadItems(at: [indexPath])
    }
}

extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.searchText = searchController.searchBar.text ?? ""
    }
}