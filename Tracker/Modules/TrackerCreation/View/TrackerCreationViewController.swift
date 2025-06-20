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
    var isEdit: Bool = false
    var onTrackerCreated: ((Tracker, TrackerCategory) -> Void)?
    
    var selectedId: UUID? = nil
    var selectedName: String? = nil
    var selectedSchedule: [WeekDay] = []
    var selectedCategory: TrackerCategory? = nil
    var selectedColor: String? = nil
    var selectedEmoji: String? = nil
    
    private let nameField: UITextField = {
        let field = UITextField()
        field.placeholder = NSLocalizedString("tracker_placeholder", comment: "")
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
    
    private lazy var emojiCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 0
        let collection = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        collection.delegate = self
        collection.dataSource = self
        collection.allowsMultipleSelection = false
        collection.register(
            EmojiCell.self,
            forCellWithReuseIdentifier: EmojiCell.identifier
        )
        collection.register(
            CategoryHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: CategoryHeaderView.identifier
        )
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()
    
    private lazy var colorCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 0
        let collection = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        collection.delegate = self
        collection.dataSource = self
        collection.allowsMultipleSelection = false
        collection.register(
            ColorCell.self,
            forCellWithReuseIdentifier: ColorCell.identifier
        )
        collection.register(
            CategoryHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: CategoryHeaderView.identifier
        )
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()
    
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()
    
    private let contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
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
        view.addSubview(scrollView)
        view.addSubview(buttonHorizontalStack)
        
        scrollView.addSubview(contentStackView)
        
        setupNameField()
        setupCategoryScheduleStack()
        setupEmojiCollection()
        setupColorCollection()
        setupActionButtons()
        
        updateSelectedData()
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor
            ),
            scrollView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            scrollView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),
            scrollView.bottomAnchor.constraint(
                equalTo: buttonHorizontalStack.topAnchor,
                constant: -16
            ),
            
            contentStackView.topAnchor.constraint(
                equalTo: scrollView.topAnchor,
            ),
            contentStackView.leadingAnchor.constraint(
                equalTo: scrollView.leadingAnchor,
                constant: 16
            ),
            contentStackView.trailingAnchor.constraint(
                equalTo: scrollView.trailingAnchor,
                constant: -16
            ),
            contentStackView.bottomAnchor.constraint(
                equalTo: scrollView.bottomAnchor
            ),
            contentStackView.widthAnchor.constraint(
                equalTo: scrollView.widthAnchor,
                constant: -32
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
    
    private func setupNameField() {
        nameField.addTarget(
            self,
            action: #selector(nameChanged),
            for: .editingChanged
        )
        
        nameField.heightAnchor.constraint(equalToConstant: 75).isActive = true
        let padded = makePaddedContainer(for: nameField, topInset: 24)
        contentStackView.addArrangedSubview(padded)
    }
    
    private func setupCategoryScheduleStack() {
        setupButton(
            categoryButton,
            action: #selector(categoryTapped)
        )
        setupButton(
            scheduleButton,
            action: #selector(scheduleTapped)
        )
        
        updateCategoryButtonSubtitle()
        updateScheduleButtonSubtitle()
        
        buttonVerticalStack.addArrangedSubview(categoryButton)
        buttonVerticalStack.addArrangedSubview(divider)
        divider.heightAnchor.constraint(equalToConstant: isHabit ? 1 : 0).isActive = true
        divider.leadingAnchor.constraint(equalTo: buttonVerticalStack.leadingAnchor, constant: 16).isActive = true
        divider.trailingAnchor.constraint(equalTo: buttonVerticalStack.trailingAnchor, constant: -16).isActive = true
        
        if isHabit {
            buttonVerticalStack.addArrangedSubview(scheduleButton)
        }
        
        categoryScheduleContainer.addSubview(buttonVerticalStack)
        
        NSLayoutConstraint.activate([
            buttonVerticalStack.topAnchor.constraint(equalTo: categoryScheduleContainer.topAnchor),
            buttonVerticalStack.bottomAnchor.constraint(equalTo: categoryScheduleContainer.bottomAnchor),
            buttonVerticalStack.leadingAnchor.constraint(equalTo: categoryScheduleContainer.leadingAnchor),
            buttonVerticalStack.trailingAnchor.constraint(equalTo: categoryScheduleContainer.trailingAnchor)
        ])
        
        let paddedContainer = makePaddedContainer(for: categoryScheduleContainer, topInset: 24)
        contentStackView.addArrangedSubview(paddedContainer)
    }
    
    private func setupButton(
        _ button: UIButton,
        action: Selector
    ) {
        button.contentHorizontalAlignment = .left
        button.titleLabel?.numberOfLines = 2
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
    
    private func updateName() {
        nameField.text = selectedName
    }
    
    private func updateEmoji() {
        if let selected = selectedEmoji,
           let index = EmojiData.all.firstIndex(of: selected) {
            let indexPath = IndexPath(item: index, section: 0)
            emojiCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
        }
    }
    
    private func updateColor() {
        if let selectedHex = selectedColor,
           let index = ColorData.all.firstIndex(where: { $0.toHex() == selectedHex }) {
            let indexPath = IndexPath(item: index, section: 0)
            colorCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
        }
    }
    
    private func updateCategoryButtonSubtitle() {
        categoryButton.setAttributedTitle(
            makeButtonTitle(NSLocalizedString("category", comment: ""), selectedCategory?.title),
            for: .normal
        )
    }
    
    private func updateScheduleButtonSubtitle() {
        let subtitle = selectedSchedule.count == WeekDay.allCases.count
        ? NSLocalizedString("every_day", comment: "")
        : selectedSchedule.map { $0.shortName }.joined(separator: ", ")
        scheduleButton.setAttributedTitle(
            makeButtonTitle(NSLocalizedString("schedule", comment: ""), subtitle),
            for: .normal
        )
    }
    
    private func makeButtonTitle(
        _ title: String,
        _ subtitle: String?
    ) -> NSAttributedString {
        let titleAttributed = NSMutableAttributedString(
            string: title,
            attributes: [
                .font: AppTextStyle.ypRegular17.font,
                .foregroundColor: UIColor.ypColorBlack
            ]
        )
        
        if let subtitle = subtitle, !subtitle.isEmpty {
            let subtitleAttributed = NSAttributedString(
                string: "\n\(subtitle)",
                attributes: [
                    .font: AppTextStyle.ypRegular17.font,
                    .foregroundColor: UIColor.ypColorGray
                ]
            )
            titleAttributed.append(subtitleAttributed)
        }
        
        return titleAttributed
    }
    
    private func setupEmojiCollection() {
        emojiCollectionView.heightAnchor.constraint(equalToConstant: 226).isActive = true
        let padded = makePaddedContainer(for: emojiCollectionView, topInset: 16)
        contentStackView.addArrangedSubview(padded)
    }
    
    private func setupColorCollection() {
        colorCollectionView.heightAnchor.constraint(equalToConstant: 226).isActive = true
        let padded = makePaddedContainer(for: colorCollectionView, topInset: 0)
        contentStackView.addArrangedSubview(padded)
    }
    
    private func setupActionButtons() {
        setupCancelButton()
        setupCreateButton()
        
        buttonHorizontalStack.addArrangedSubview(cancelButton)
        buttonHorizontalStack.addArrangedSubview(createButton)
        
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
        cancelButton.setTitle(NSLocalizedString("cancel", comment: ""), for: .normal)
        cancelButton.setTitleColor(.ypColorRed, for: .normal)
        cancelButton.titleLabel?.font = AppTextStyle.ypMedium16.font
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
        createButton.setTitle(NSLocalizedString(isEdit ? "save" : "create", comment: ""), for: .normal)
        createButton.setTitleColor(.ypColorWhite, for: .normal)
        cancelButton.titleLabel?.font = AppTextStyle.ypMedium16.font
        createButton.backgroundColor = .ypColorGray
        createButton.layer.cornerRadius = 16
        createButton.addTarget(
            self,
            action: #selector(createTapped),
            for: .touchUpInside
        )
    }
    
    private func makePaddedContainer(for view: UIView, topInset: CGFloat) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: container.topAnchor, constant: topInset),
            view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        return container
    }
    
    private func updateSelectedData() {
        if (isEdit) {
            updateName()
            updateEmoji()
            updateColor()
            updateCategoryButtonSubtitle()
            updateScheduleButtonSubtitle()
            updateCreateButtonState()
        }
    }
    
    private func updateCreateButtonState() {
        let isReady = !(selectedName?.isEmpty ?? true)
        && selectedEmoji != nil
        && selectedColor != nil
        && selectedCategory != nil
        && (!isHabit || !selectedSchedule.isEmpty)
        
        createButton.isEnabled = isReady
        createButton.backgroundColor = isReady ? .ypColorBlack : .ypColorGray
    }
    
    // MARK: - Actions
    
    @objc private func endEditing() {
        view.endEditing(true)
    }
    
    @objc private func nameChanged() {
        selectedName = nameField.text
        updateCreateButtonState()
    }
    
    @objc private func categoryTapped() {
        let context = CoreDataManager.shared.viewContext
        let categoryStore = TrackerCategoryStore(context: context)
        let viewModel = CategoriesListViewModel(
            categoryStore: categoryStore
        )
        let categoriesListVC = CategoriesListViewController(
            viewModel: viewModel
        )
        categoriesListVC.selectedСategory = self.selectedCategory
        categoriesListVC.title = NSLocalizedString("category", comment: "")
        categoriesListVC.onSave = { [weak self] selected in
            self?.selectedCategory = selected
            self?.updateCategoryButtonSubtitle()
            self?.updateCreateButtonState()
        }
        let navController = UINavigationController(rootViewController: categoriesListVC)
        navController.navigationBar.titleTextAttributes = AppTextStyle.ypMedium16.attributes
        present(navController, animated: true)
    }
    
    @objc private func scheduleTapped() {
        let scheduleVC = ScheduleViewController()
        scheduleVC.selectedDays = self.selectedSchedule
        scheduleVC.title = NSLocalizedString("schedule", comment: "")
        scheduleVC.onSave = { [weak self] selected in
            self?.selectedSchedule = selected
            self?.updateScheduleButtonSubtitle()
            self?.updateCreateButtonState()
        }
        let navController = UINavigationController(rootViewController: scheduleVC)
        navController.navigationBar.titleTextAttributes = AppTextStyle.ypMedium16.attributes
        present(navController, animated: true)
    }
    
    @objc private func createTapped() {
        guard let category = selectedCategory else {
            return
        }
        
        let tracker = Tracker(
            id: selectedId ?? UUID(),
            name: selectedName ?? "",
            color: selectedColor ?? "",
            emoji: selectedEmoji ?? "",
            schedule: isHabit ? selectedSchedule : []
        )
        let updatedCategory = TrackerCategory(
            title: category.title,
            trackers: [tracker]
        )
        
        onTrackerCreated?(tracker, updatedCategory)
        dismiss(animated: true)
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
}

extension TrackerCreationViewController: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        switch collectionView {
        case emojiCollectionView:
            return EmojiData.all.count
        case colorCollectionView:
            return ColorData.all.count
        default:
            return 0
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        if collectionView == emojiCollectionView {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: EmojiCell.identifier,
                for: indexPath
            ) as! EmojiCell
            cell.configure(with: EmojiData.all[indexPath.item])
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ColorCell.identifier,
                for: indexPath
            ) as! ColorCell
            cell.configure(with: ColorData.all[indexPath.item])
            return cell
        }
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
        
        let title = if collectionView == emojiCollectionView {
            "Emoji"
        } else {
            "Цвет"
        }
        
        header.configure(with: title)
        return header
    }
}

extension TrackerCreationViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        if collectionView == emojiCollectionView {
            selectedEmoji = EmojiData.all[indexPath.item]
        } else {
            selectedColor = ColorData.all[indexPath.item].toHex()
        }
        updateCreateButtonState()
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: 52, height: 52)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 46)
    }
}
