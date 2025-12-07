import UIKit

final class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupAppearance()
        setupTabs()
    }
    
    private func setupAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        appearance.shadowColor = .separator
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }
    
    private func setupTabs() {
        let trackers = UINavigationController(rootViewController: TrackersViewController())
        trackers.navigationBar.prefersLargeTitles = true
        trackers.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(resource: .tabTrackers),
            selectedImage: nil
        )
        
        let statistics = UINavigationController(rootViewController: StatisticsViewController())
        statistics.navigationBar.prefersLargeTitles = true
        statistics.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(resource: .tabStats),
            selectedImage: nil
        )
        
        viewControllers = [trackers, statistics]
    }
}
