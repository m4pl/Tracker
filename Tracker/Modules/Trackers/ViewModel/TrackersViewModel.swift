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
    
    // MARK: - Init
    init() {
        filterVisibleCategories()
    }
    
    // MARK: - Tracker Operations
    
    func addTracker(_ tracker: Tracker, toCategoryTitle title: String) {
        if let index = allCategories.firstIndex(where: { $0.title == title }) {
            let category = allCategories[index]
            let newCategory = TrackerCategory(
                title: category.title,
                trackers: category.trackers + [tracker]
            )
            allCategories[index] = newCategory
        } else {
            let newCategory = TrackerCategory(title: title, trackers: [tracker])
            allCategories.append(newCategory)
        }
        
        filterVisibleCategories()
    }
    
    func toggleTrackerCompletion(_ trackerId: UUID) {
        let calendar = Calendar.current
        
        if let index = completedTrackers.firstIndex(where: {
            $0.trackerId == trackerId && calendar.isDate($0.date, inSameDayAs: selectedDate)
        }) {
            completedTrackers.remove(at: index)
        } else {
            completedTrackers.append(.init(trackerId: trackerId, date: selectedDate))
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
    
    // MARK: - Private Helpers
    
    private func filterVisibleCategories() {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: selectedDate)
        let adjustedWeekday = (weekday + 5) % 7 + 1
        let day = WeekDay(rawValue: adjustedWeekday) ?? .monday
        
        let filtered = allCategories.map { category in
            let filteredTrackers = category.trackers.filter {$0.schedule.contains(day)}
            return TrackerCategory(title: category.title, trackers: filteredTrackers)
        }.filter { !$0.trackers.isEmpty }
        
        visibleCategories.send(filtered)
    }
}
