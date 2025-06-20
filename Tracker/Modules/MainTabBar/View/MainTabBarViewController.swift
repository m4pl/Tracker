//
//  MainTabBarController.swift
//  Tracker
//
//  Created by Matvei Plokhov on 04.06.2025.
//

import UIKit

final class MainTabBarViewController: UITabBarController {

    private let trackersViewModel: TrackersViewModel
    private let statisticsViewModel: StatisticsViewModel

    init(trackersViewModel: TrackersViewModel, statisticsViewModel: StatisticsViewModel) {
        self.trackersViewModel = trackersViewModel
        self.statisticsViewModel = statisticsViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let trackersVC = UINavigationController(
            rootViewController: TrackersViewController(
                viewModel: trackersViewModel
            )
        )
        let statisticsVC = UINavigationController(
            rootViewController: StatisticsViewController(
                viewModel: statisticsViewModel
            )
        )

        trackersVC.tabBarItem = UITabBarItem(
            title: NSLocalizedString("trackers", comment: ""),
            image: UIImage(named: "tab_trackers_logo"),
            tag: 0
        )
        statisticsVC.tabBarItem = UITabBarItem(
            title: NSLocalizedString("statistics", comment: ""),
            image: UIImage(named: "tab_statistics_logo"),
            tag: 1
        )

        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .ypColorWhite

        tabBar.tintColor = .systemBlue
        tabBar.unselectedItemTintColor = .gray
        tabBar.standardAppearance = appearance

        viewControllers = [trackersVC, statisticsVC]
    }
}
