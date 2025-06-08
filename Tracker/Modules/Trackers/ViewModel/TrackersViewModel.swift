//
//  TrackersViewModel.swift
//  Tracker
//
//  Created by Matvei Plokhov on 04.06.2025.
//

import Foundation
import Combine

final class TrackersViewModel {
    
    // MARK: - Public Outputs
    private(set) var visibleCategories = CurrentValueSubject<[TrackerCategory], Never>([])
    @Published private(set) var completedTrackers: [TrackerRecord] = []
    
    var selectedDate: Date = Date() {
        didSet {
            filterVisibleCategories()
        }
    }
    
    // MARK: - Data Storage
    private var allCategories: [TrackerCategory] = []
    
    // MARK: - Core Data Stores
    private let categoryStore: TrackerCategoryStore
    private let trackerStore: TrackerStore
    private let recordStore: TrackerRecordStore
    
    // MARK: - Init
    init(
        categoryStore: TrackerCategoryStore,
        trackerStore: TrackerStore,
        recordStore: TrackerRecordStore
    ) {
        self.categoryStore = categoryStore
        self.trackerStore = trackerStore
        self.recordStore = recordStore
        
        categoryStore.delegate = self
        recordStore.delegate = self
        
        reloadAll()
    }
    
    // MARK: - Public Methods
    
    func addTracker(_ tracker: Tracker, _ category: TrackerCategory) {
        do {
            try trackerStore.add(tracker)
            try categoryStore.add(category)
        } catch {
            print("Error adding tracker: \(error)")
        }
    }
    
    func toggleTrackerCompletion(_ trackerId: UUID) {
        let calendar = Calendar.current
        let selectedDay = selectedDate
        
        if let record = completedTrackers.first(where: {
            $0.trackerId == trackerId && calendar.isDate($0.date, inSameDayAs: selectedDay)
        }) {
            try? recordStore.delete(record)
        } else {
            let newRecord = TrackerRecord(
                trackerId: trackerId,
                date: selectedDay
            )
            try? recordStore.add(newRecord)
        }
    }
    
    func isTrackerCompletedToday(_ trackerId: UUID) -> Bool {
        return completedTrackers.contains {
            $0.trackerId == trackerId && Calendar.current.isDate($0.date, inSameDayAs: selectedDate)
        }
    }
    
    func completedDaysCount(for trackerId: UUID) -> Int {
        return completedTrackers.filter { $0.trackerId == trackerId }.count
    }
    
    // MARK: - Private
    
    private func reloadAll() {
        loadCategories()
        loadRecords()
    }
    
    private func loadCategories() {
        do {
            let categories = try categoryStore.getCategories()
            self.allCategories = categories
            filterVisibleCategories()
        } catch {
            print("Error loading categories: \(error)")
        }
    }
    
    private func loadRecords() {
        self.completedTrackers = recordStore.getRecords()
    }
    
    private func filterVisibleCategories() {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: selectedDate)
        let adjustedWeekday = (weekday + 5) % 7 + 1
        let day = WeekDay(rawValue: adjustedWeekday) ?? .monday
        
        let filtered = allCategories.map { category in
            let filteredTrackers = category.trackers.filter { $0.schedule.contains(day) }
            return TrackerCategory(title: category.title, trackers: filteredTrackers)
        }.filter { !$0.trackers.isEmpty }
        
        visibleCategories.send(filtered)
    }
}

extension TrackersViewModel: TrackerCategoryStoreDelegate {
    func trackerCategoryStoreDidChange(_ store: TrackerCategoryStore) {
        loadCategories()
    }
}

extension TrackersViewModel: TrackerRecordStoreDelegate {
    func trackerRecordStoreDidChange(_ store: TrackerRecordStore) {
        loadRecords()
    }
}
