import UIKit

final class OnboardingPageViewController: UIViewController {
    
    private lazy var pageViewController: UIPageViewController = {
        let controller = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal
        )
        controller.dataSource = self
        controller.delegate = self
        return controller
    }()
    
    private lazy var pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Отслеживайте только\nто, что хотите",
            backgroundImage: UIImage(resource: .onboardingBg1)
        ),
        OnboardingPage(
            title: "Даже если это\nне литры воды и йога",
            backgroundImage: UIImage(resource: .onboardingBg2)
        )
    ]
    
    private lazy var pageControllers: [OnboardingPageContentViewController] = {
        pages.map { OnboardingPageContentViewController(page: $0) }
    }()
    
    private let pageControl: UIPageControl = {
        let control = UIPageControl()
        control.currentPageIndicatorTintColor = .label
        control.pageIndicatorTintColor = UIColor.label.withAlphaComponent(0.3)
        control.tintColor = UIColor(resource: .black)
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Вот это технологии!", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(UIColor(resource: .white), for: .normal)
        button.backgroundColor = UIColor(resource: .black)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupPageViewController()
        setupButton()
        setupPageControl()
    }
    
    private func setupPageViewController() {
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)
        
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pageViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            pageViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        pageViewController.setViewControllers(
            [pageControllers.first].compactMap { $0 },
            direction: .forward,
            animated: true
        )
    }
    
    private func setupPageControl() {
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        
        view.addSubview(pageControl)
        
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: actionButton.topAnchor, constant: -16)
        ])
    }
    
    private func setupButton() {
        actionButton.addTarget(self, action: #selector(handleButtonTap), for: .touchUpInside)
        view.addSubview(actionButton)
        
        NSLayoutConstraint.activate([
            actionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            actionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            actionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50)
        ])
    }
    
    @objc private func handleButtonTap() {
        UserDefaults.standard.set(true, forKey: OnboardingStorage.hasSeenOnboardingKey)
        switchToMain()
    }
    
    private func switchToMain() {
        let mainController = MainTabBarController()
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let sceneDelegate = windowScene.delegate as? SceneDelegate,
           let window = sceneDelegate.window {
            
            window.rootViewController = mainController
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
        } else {
            present(mainController, animated: true)
        }
    }
}

extension OnboardingPageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let page = viewController as? OnboardingPageContentViewController,
              let currentIndex = pageControllers.firstIndex(of: page) else { return nil }
        let previousIndex = currentIndex - 1
        return previousIndex >= 0 ? pageControllers[previousIndex] : nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let page = viewController as? OnboardingPageContentViewController,
              let currentIndex = pageControllers.firstIndex(of: page) else { return nil }
        let nextIndex = currentIndex + 1
        return nextIndex < pageControllers.count ? pageControllers[nextIndex] : nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed, let visibleController = pageViewController.viewControllers?.first,
              let page = visibleController as? OnboardingPageContentViewController,
              let index = pageControllers.firstIndex(of: page) else { return }
        pageControl.currentPage = index
    }
}
