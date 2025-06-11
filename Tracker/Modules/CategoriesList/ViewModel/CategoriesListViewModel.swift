//
//  CategoriesListViewModel.swift
//  Tracker
//
//  Created by mpplokhov on 11.06.2025.
//

import Foundation
import Combine

final class CategoriesListViewModel {
    
    // MARK: - Public Outputs
    private(set) var allCategories = CurrentValueSubject<[TrackerCategory], Never>([])
    let selectedCategoryPublisher = PassthroughSubject<TrackerCategory, Never>()

    // MARK: - Core Data Stores
    private let categoryStore: TrackerCategoryStore
    
    // MARK: - Init
    init(
        categoryStore: TrackerCategoryStore
    ) {
        self.categoryStore = categoryStore
        categoryStore.delegate = self
        loadCategories()
    }

    // MARK: - Public
    func selectCategory(at index: Int) {
        guard index < allCategories.value.count else { return }
        let category = allCategories.value[index]
        selectedCategoryPublisher.send(category)
    }

    // MARK: - Private
    
    private func loadCategories() {
        do {
            let categories = try categoryStore.getCategories()
            allCategories.send(categories)
        } catch {
            print("Error getting categories: \(error)")
        }
    }
}

extension CategoriesListViewModel: TrackerCategoryStoreDelegate {
    func trackerCategoryStoreDidChange(_ store: TrackerCategoryStore) {
        loadCategories()
    }
}
