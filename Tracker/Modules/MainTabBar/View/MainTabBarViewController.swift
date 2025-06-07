//
//  MainTabBarController.swift
//  Tracker
//
//  Created by Matvei Plokhov on 04.06.2025.
//

import UIKit

final class MainTabBarViewController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let trackersVC = UINavigationController(
            rootViewController: TrackersViewController()
        )
        let statisticsVC = UINavigationController(
            rootViewController: StatisticsViewController()
        )

        trackersVC.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(named: "tab_trackers_logo"),
            tag: 0
        )
        statisticsVC.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(named: "tab_statistics_logo"),
            tag: 1
        )

        view.backgroundColor = .ypColorWhite
        tabBar.isTranslucent = false

        viewControllers = [trackersVC, statisticsVC]
    }
}
