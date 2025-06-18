//
//  OnboardingManager.swift
//  Tracker
//
//  Created by mpplokhov on 11.06.2025.
//

import UIKit

final class OnboardingManager {

    static let shared = OnboardingManager()
    private let onboardingKey = "hasSeenOnboarding"

    private init() {}

    var hasSeenOnboarding: Bool {
        return UserDefaults.standard.bool(forKey: onboardingKey)
    }

    func setHasSeenOnboarding() {
        UserDefaults.standard.set(true, forKey: onboardingKey)
    }

    func initialViewController() -> UIViewController {
        if hasSeenOnboarding {
            let context = CoreDataManager.shared.viewContext
            let trackersViewModel = TrackersViewModel(
                categoryStore: TrackerCategoryStore(context: context),
                trackerStore: TrackerStore(context: context),
                recordStore: TrackerRecordStore(context: context)
            )
            return MainTabBarViewController(
                trackersViewModel: trackersViewModel
            )
        } else {
            return OnboardingPageViewController(
                transitionStyle: .scroll,
                navigationOrientation: .horizontal
            )
        }
    }
}
