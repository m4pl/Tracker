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

    @Published var currentFilter: FilterType = .all {
        didSet {
            if currentFilter == .today {
                selectedDate = Date()
            } else {
                filterVisibleCategories()
            }
        }
    }

    var isFilterApplied: Bool {
        return !searchText.isEmpty || currentFilter != .all
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
        trackerStore.delegate = self
        
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
    
    func editTracker(_ tracker: Tracker, _ category: TrackerCategory) {
        do {
            try trackerStore.edit(tracker)
            try categoryStore.edit(category)
        } catch {
            print("Error editing tracker: \(error)")
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
    
    func getTrackerCategory(_ tracker: Tracker) -> TrackerCategory? {
        do {
            let categories = try categoryStore.getCategories()
            for category in categories {
                if category.trackers.contains(where: { $0.id == tracker.id }) {
                    return category
                }
            }
        } catch {
            print("Error getting category: \(error)")
        }
        
        return nil
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
        let currentDay = WeekDay(rawValue: adjustedWeekday) ?? .monday

        let completedTodayIds: Set<UUID> = Set(
            completedTrackers
                .filter { calendar.isDate($0.date, inSameDayAs: selectedDate) }
                .map { $0.trackerId }
        )

        let filteredCategories = allCategories.map { category -> TrackerCategory in
            let filteredTrackers = category.trackers.filter { tracker in
                let matchesSearch = searchText.isEmpty || tracker.name.lowercased().contains(searchText.lowercased())
                let isScheduledToday = tracker.schedule.isEmpty || tracker.schedule.contains(currentDay)
                let isCompleted = completedTodayIds.contains(tracker.id)

                switch currentFilter {
                case .all, .today:
                    return matchesSearch && isScheduledToday

                case .completed:
                    return matchesSearch && isScheduledToday && isCompleted

                case .notCompleted:
                    return matchesSearch && isScheduledToday && !isCompleted
                }
            }

            return TrackerCategory(title: category.title, trackers: filteredTrackers)
        }
        .filter { !$0.trackers.isEmpty }

        let filteredTrackersFlat = filteredCategories.flatMap { $0.trackers }
        let filteredPinned = pinnedTrackers.filter { pinned in
            filteredTrackersFlat.contains(where: { $0.id == pinned.tracker.id })
        }

        let categoriesWithoutPinned = filteredCategories.map { category -> TrackerCategory in
            let trackersWithoutPinned = category.trackers.filter { tracker in
                !filteredPinned.contains(where: { $0.tracker.id == tracker.id })
            }
            return TrackerCategory(title: category.title, trackers: trackersWithoutPinned)
        }
        .filter { !$0.trackers.isEmpty }

        var finalCategories: [TrackerCategory] = []

        if !filteredPinned.isEmpty {
            let pinnedCategory = TrackerCategory(
                title: NSLocalizedString("pinned", comment: ""),
                trackers: filteredPinned.map { $0.tracker }
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

extension TrackersViewModel: TrackerStoreDelegate {
    func trackerStoreDidChange(_ store: TrackerStore) {
        loadPinnedTrackers()
        loadCategories()
    }
}

extension TrackersViewModel: TrackerRecordStoreDelegate {
    func trackerRecordStoreDidChange(_ store: TrackerRecordStore) {
        loadRecords()
        loadCategories()
    }
}

extension TrackersViewModel: TrackerPinnedStoreDelegate {
    func trackerPinnedStoreDidChange(_ store: TrackerPinnedStore) {
        loadPinnedTrackers()
        loadCategories()
    }
}
