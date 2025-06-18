//
//  NewCategoryViewModel.swift
//  Tracker
//
//  Created by mpplokhov on 11.06.2025.
//

import Foundation

final class NewCategoryViewModel {
    
    // MARK: - Core Data Stores
    private let categoryStore: TrackerCategoryStore
    
    // MARK: - Init
    init(
        categoryStore: TrackerCategoryStore
    ) {
        self.categoryStore = categoryStore
    }

    // MARK: - Public
    func createCategory(_ name: String) {
        categoryStore.create(name)
    }
}
