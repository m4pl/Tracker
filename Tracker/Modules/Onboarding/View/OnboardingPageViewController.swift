//
//  OnboardingPageViewController.swift
//  Tracker
//
//  Created by mpplokhov on 10.06.2025.
//

import UIKit

class OnboardingPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    private let pages: [OnboardingContentViewController] = {
        let page1 = OnboardingContentViewController()
        page1.imageName = "onboarding1"
        page1.titleText = NSLocalizedString("page1_title", comment: "")
        
        let page2 = OnboardingContentViewController()
        page2.imageName = "onboarding2"
        page2.titleText = NSLocalizedString("page2_title", comment: "")
        
        return [page1, page2]
    }()
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = .ypColorBlack
        pageControl.pageIndicatorTintColor = .ypColorBlack.withAlphaComponent(0.3)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    private lazy var button: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("wow_tech", comment: ""), for: .normal)
        button.backgroundColor = .ypColorBlack
        button.setTitleColor(.ypColorWhite, for: .normal)
        button.titleLabel?.font = AppTextStyle.ypMedium16.font
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        dataSource = self
        delegate = self
        setViewControllers([pages[0]], direction: .forward, animated: true, completion: nil)
        
        button.addTarget(
            self,
            action: #selector(buttonClicked),
            for: .touchUpInside
        )
        
        view.addSubview(pageControl)
        view.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 20
            ),
            button.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -20
            ),
            button.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -50
            ),
            button.heightAnchor.constraint(
                equalToConstant: 60
            ),
            
            pageControl.bottomAnchor.constraint(
                equalTo: button.topAnchor,
                constant: -24
            ),
            pageControl.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            )
        ])
    }
    
    @objc private func buttonClicked() {
        goToMainApp()
    }

    private func goToMainApp() {
        OnboardingManager.shared.setHasSeenOnboarding()

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController = OnboardingManager.shared.initialViewController()
            window.makeKeyAndVisible()
        }
    }

    // MARK: - PageViewController Data Source
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController as! OnboardingContentViewController), index > 0 else {
            return nil
        }
        return pages[index - 1]
    }
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController as! OnboardingContentViewController), index < pages.count - 1 else {
            return nil
        }
        return pages[index + 1]
    }
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        if let currentVC = viewControllers?.first as? OnboardingContentViewController,
           let index = pages.firstIndex(of: currentVC) {
            pageControl.currentPage = index
        }
    }
}
