//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by Matvei Plokhov on 04.06.2025.
//

import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testTrackersViewController_LightTheme() throws {
        let context = CoreDataManager.shared.viewContext
        let trackersViewModel = TrackersViewModel(
            categoryStore: TrackerCategoryStore(context: context),
            trackerStore: TrackerStore(context: context),
            recordStore: TrackerRecordStore(context: context),
            pinnedStore: TrackerPinnedStore(context: context),
        )
        let statisticsViewModel = StatisticsViewModel(
            recordStore: TrackerRecordStore(context: context)
        )
        let vc = MainTabBarViewController(
            trackersViewModel: trackersViewModel,
            statisticsViewModel: statisticsViewModel,
        )

        assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .light)))
    }

    func testTrackersViewController_DarkTheme() {
        let context = CoreDataManager.shared.viewContext
        let trackersViewModel = TrackersViewModel(
            categoryStore: TrackerCategoryStore(context: context),
            trackerStore: TrackerStore(context: context),
            recordStore: TrackerRecordStore(context: context),
            pinnedStore: TrackerPinnedStore(context: context),
        )
        let statisticsViewModel = StatisticsViewModel(
            recordStore: TrackerRecordStore(context: context)
        )
        let vc = MainTabBarViewController(
            trackersViewModel: trackersViewModel,
            statisticsViewModel: statisticsViewModel,
        )


        assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }
}
