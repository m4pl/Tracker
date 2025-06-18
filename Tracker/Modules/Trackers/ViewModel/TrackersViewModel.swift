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
    @Published private(set) var pinnedTrackers: [PinnedTracker] = []
    @Published private(set) var searchText: String = ""
    
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
    private let pinnedStore: TrackerPinnedStore
    
    // MARK: - Init
    init(
        categoryStore: TrackerCategoryStore,
        trackerStore: TrackerStore,
        recordStore: TrackerRecordStore,
        pinnedStore: TrackerPinnedStore,
    ) {
        self.categoryStore = categoryStore
        self.trackerStore = trackerStore
        self.recordStore = recordStore
        self.pinnedStore = pinnedStore
        
        categoryStore.delegate = self
        recordStore.delegate = self
        pinnedStore.delegate = self
        
        reloadAll()
    }
    
    // MARK: - Public Methods
    
    func search(_ query: String) {
        searchText = query
    }
    
    func addTracker(_ tracker: Tracker, _ category: TrackerCategory) {
        do {
            try trackerStore.add(tracker)
            try categoryStore.add(category)
        } catch {
            print("Error adding tracker: \(error)")
        }
    }
    
    func deleteTracker(_ tracker: Tracker) {
        do {
            try trackerStore.delete(tracker)
            try categoryStore.delete(tracker)
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
            do {
                try recordStore.add(newRecord)
            } catch {
                print("Error adding record: \(error)")
            }
        }
    }
    
    func toggleTrackerPin(_ tracker: Tracker) {
        let tracker = PinnedTracker(
            tracker: tracker,
            date: selectedDate
        )
        
        do {
            try pinnedStore.toggle(tracker)
        } catch {
            print("Error pinning/unpinning tracker: \(error)")
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

    func filterVisibleCategories() {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: selectedDate)
        let adjustedWeekday = (weekday + 5) % 7 + 1
        let day = WeekDay(rawValue: adjustedWeekday) ?? .monday
        
        let filteredCategories = allCategories.map { category -> TrackerCategory in
            let filteredTrackers = category.trackers.filter { tracker in
                let matchesSearch = searchText.isEmpty || tracker.name.lowercased().contains(searchText.lowercased())
                
                if tracker.schedule.isEmpty {
                    let hasAnyRecord = completedTrackers.contains { $0.trackerId == tracker.id }
                    let completedToday = completedTrackers.contains {
                        $0.trackerId == tracker.id && calendar.isDate($0.date, inSameDayAs: selectedDate)
                    }
                    return matchesSearch && (!hasAnyRecord || completedToday)
                } else {
                    return matchesSearch && tracker.schedule.contains(day)
                }
            }
            return TrackerCategory(title: category.title, trackers: filteredTrackers)
        }.filter { !$0.trackers.isEmpty }
        
        let filteredTrackersFlat = filteredCategories.flatMap { $0.trackers }
        let filteredPinned = pinnedTrackers.filter { pinned in
            filteredTrackersFlat.contains(where: { $0.id == pinned.tracker.id })
        }

        let categoriesWithoutPinned = filteredCategories.map { category -> TrackerCategory in
            let trackersWithoutPinned = category.trackers.filter { tracker in
                !filteredPinned.contains(where: { $0.tracker.id == tracker.id })
            }
            return TrackerCategory(title: category.title, trackers: trackersWithoutPinned)
        }.filter { !$0.trackers.isEmpty }
        
        var finalCategories: [TrackerCategory] = []
        if !filteredPinned.isEmpty {
            let pinnedTrackersOnly = filteredPinned.map { $0.tracker }
            let pinnedCategory = TrackerCategory(
                title: NSLocalizedString("pinned", comment: ""),
                trackers: pinnedTrackersOnly
            )
            finalCategories.append(pinnedCategory)
        }
        
        finalCategories.append(contentsOf: categoriesWithoutPinned)
        
        visibleCategories.send(finalCategories)
    }


    
    // MARK: - Private
    
    private func reloadAll() {
        loadPinnedTrackers()
        loadCategories()
        loadRecords()
    }
    
    private func loadPinnedTrackers() {
        pinnedTrackers = pinnedStore.getPinned()
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
}

extension TrackersViewModel: TrackerCategoryStoreDelegate {
    func trackerCategoryStoreDidChange(_ store: TrackerCategoryStore) {
        loadCategories()
    }
}

extension TrackersViewModel: TrackerRecordStoreDelegate {
    func trackerRecordStoreDidChange(_ store: TrackerRecordStore) {
        loadCategories()
        loadRecords()
    }
}

extension TrackersViewModel: TrackerPinnedStoreDelegate {
    func trackerPinnedStoreDidChange(_ store: TrackerPinnedStore) {
        loadPinnedTrackers()
        loadCategories()
    }
}
