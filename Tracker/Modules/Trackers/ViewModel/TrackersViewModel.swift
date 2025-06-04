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
        loadMockData()
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
        var calendar = Calendar.current
        calendar.timeZone = .current
        
        let weekday = calendar.component(.weekday, from: selectedDate)
        let day = WeekDay(rawValue: weekday) ?? .monday
        
        let filtered = allCategories.map { category in
            let filtered = category.trackers.filter { $0.schedule.contains(day) }
            return TrackerCategory(title: category.title, trackers: filtered)
        }.filter { !$0.trackers.isEmpty }
        
        visibleCategories.send(filtered)
    }
    
    private func loadMockData() {
        let redHeart = Tracker(
            id: UUID(),
            name: "Поливать растения",
            color: .systemGreen,
            emoji: "❤️",
            schedule: [WeekDay.thursday,WeekDay.saturday]
        )
        let smilingCatWithHeartEyes = Tracker(
            id: UUID(),
            name: "Кошка заслонила камеру на созвоне",
            color: .systemOrange,
            emoji: "😻",
            schedule: WeekDay.allCases
        )
        let hibiscus = Tracker(
            id: UUID(),
            name: "Бабушка прислала открытку в вотсапе",
            color: .systemRed,
            emoji: "🌺",
            schedule: WeekDay.allCases
        )
        let girl = Tracker(
            id: UUID(),
            name: "Свидания в апреле",
            color: .systemPurple,
            emoji: "👧",
            schedule: [WeekDay.wednesday]
        )
        let goodMood = Tracker(
            id: UUID(),
            name: "Хорошее настроение",
            color: .systemPurple,
            emoji: "🙂",
            schedule: WeekDay.allCases
        )
        let mildAnxiety = Tracker(
            id: UUID(),
            name: "Легкая тревожность",
            color: .systemBlue,
            emoji: "😪",
            schedule: WeekDay.allCases
        )
        let homeComfort = TrackerCategory(
            title: "Домашний уют",
            trackers: [redHeart]
        )
        let joyfulLittleThings = TrackerCategory(
            title: "Радостные мелочи",
            trackers: [smilingCatWithHeartEyes, hibiscus, girl]
        )
        let feelings = TrackerCategory(
            title: "Самочувствие",
            trackers: [goodMood, mildAnxiety]
        )
        
        allCategories = [homeComfort, joyfulLittleThings, feelings]
    }
}
