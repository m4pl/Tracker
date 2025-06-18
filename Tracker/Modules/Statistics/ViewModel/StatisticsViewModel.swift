//
//  StatisticsViewModel.swift
//  Tracker
//
//  Created by mpplokhov on 19.06.2025.
//

import Combine

final class StatisticsViewModel: ObservableObject {

    @Published private(set) var completedTrackersCount: Int = 0

    private let recordStore: TrackerRecordStore
    private var cancellables = Set<AnyCancellable>()

    init(recordStore: TrackerRecordStore) {
        self.recordStore = recordStore
        self.recordStore.delegate = self
        updateCompletedTrackersCount()
    }

    private func updateCompletedTrackersCount() {
        let records = recordStore.getRecords()
        completedTrackersCount = records.count
    }
}

extension StatisticsViewModel: TrackerRecordStoreDelegate {
    func trackerRecordStoreDidChange(_ store: TrackerRecordStore) {
        updateCompletedTrackersCount()
    }
}
