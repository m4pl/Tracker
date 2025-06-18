//
//  MainTabBarController.swift
//  Tracker
//
//  Created by Matvei Plokhov on 04.06.2025.
//

import UIKit

final class MainTabBarViewController: UITabBarController {

    private let trackersViewModel: TrackersViewModel

    init(trackersViewModel: TrackersViewModel) {
        self.trackersViewModel = trackersViewModel
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
            rootViewController: StatisticsViewController()
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

        view.backgroundColor = .ypColorWhite
        tabBar.isTranslucent = false

        viewControllers = [trackersVC, statisticsVC]
    }
}
