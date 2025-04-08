import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)

        if isFirstLaunch() {
            let onboardingVC = OnboardingViewController()
            let nav = UINavigationController(rootViewController: onboardingVC)
            window?.rootViewController = nav
        }
        else if !isLoggedIn() {
            let loginVC = LoginViewController()
            let nav = UINavigationController(rootViewController: loginVC)
            window?.rootViewController = nav
        }
        else {
            window?.rootViewController = createTabBarController()
        }

        window?.makeKeyAndVisible()
    }

    func createTabBarController() -> UITabBarController {
        let tabBarController = ModernTabBarController()
        
        let accentColor = UIColor(red: 76/255, green: 187/255, blue: 123/255, alpha: 1.0)
        
        let miniGamesVC = MiniGamesViewController()
        let miniGamesNav = UINavigationController(rootViewController: miniGamesVC)
        let miniGamesItem = UITabBarItem(
            title: "Mini Games",
            image: UIImage(systemName: "gamecontroller"),
            tag: 0
        )
        miniGamesNav.tabBarItem = miniGamesItem
        
        let resourcesVC = ResourcesViewController()
        let resourcesNav = UINavigationController(rootViewController: resourcesVC)
        let resourcesItem = UITabBarItem(
            title: "Resources",
            image: UIImage(systemName: "book"),
            tag: 1
        )
        resourcesNav.tabBarItem = resourcesItem
        
        let leaderboardVC = LeaderboardViewController()
        let leaderboardNav = UINavigationController(rootViewController: leaderboardVC)
        let leaderboardItem = UITabBarItem(
            title: "Leaderboard",
            image: UIImage(systemName: "list.number"),
            tag: 2
        )
        leaderboardNav.tabBarItem = leaderboardItem
        
        let profileVC = ProfileViewController()
        let profileNav = UINavigationController(rootViewController: profileVC)
        let profileItem = UITabBarItem(
            title: "Profile",
            image: UIImage(systemName: "person.crop.circle"),
            tag: 3
        )
        profileNav.tabBarItem = profileItem
        
        tabBarController.viewControllers = [
            miniGamesNav,
            resourcesNav,
            leaderboardNav,
            profileNav
        ]
        
        tabBarController.tabBar.tintColor = accentColor
        tabBarController.tabBar.unselectedItemTintColor = UIColor.gray.withAlphaComponent(0.6)
        tabBarController.accentColor = accentColor
        
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = .white
        
        tabBarAppearance.shadowColor = UIColor.black.withAlphaComponent(0.1)
        tabBarAppearance.shadowImage = createShadowImage()
        
        tabBarController.tabBar.standardAppearance = tabBarAppearance
        if #available(iOS 15.0, *) {
            tabBarController.tabBar.scrollEdgeAppearance = tabBarAppearance
        }

        return tabBarController
    }
    
    private func createShadowImage() -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(UIColor.black.withAlphaComponent(0.1).cgColor)
        context?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? UIImage()
    }

    private func isFirstLaunch() -> Bool {
        let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        if !hasCompletedOnboarding {
            return true
        }
        return false
    }

    private func isLoggedIn() -> Bool {
        return UserDefaults.standard.bool(forKey: "isLoggedIn") == true
    }

    func sceneDidDisconnect(_ scene: UIScene) { }
    func sceneDidBecomeActive(_ scene: UIScene) { }
    func sceneWillResignActive(_ scene: UIScene) { }
    func sceneWillEnterForeground(_ scene: UIScene) { }
    func sceneDidEnterBackground(_ scene: UIScene) { }
}

// MARK: - Modern Tab Bar Controller
class ModernTabBarController: UITabBarController {
    
    var accentColor: UIColor = .systemGreen {
        didSet {
            updateSelectionIndicator()
        }
    }
    
    private var indicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGreen
        view.layer.cornerRadius = 2
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var indicatorCenterXConstraint: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupIndicator()
        delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateSelectionIndicator(animated: false)
    }
    
    private func setupIndicator() {
        tabBar.addSubview(indicatorView)
        
        NSLayoutConstraint.activate([
            indicatorView.bottomAnchor.constraint(equalTo: tabBar.topAnchor, constant: 4),
            indicatorView.heightAnchor.constraint(equalToConstant: 4),
            indicatorView.widthAnchor.constraint(equalToConstant: 64)
        ])
        
        indicatorCenterXConstraint = indicatorView.centerXAnchor.constraint(equalTo: tabBar.leadingAnchor)
        indicatorCenterXConstraint?.isActive = true
        
        updateSelectionIndicator(animated: false)
    }
    
    private func updateSelectionIndicator(animated: Bool = true) {
        guard let items = tabBar.items, let selectedItem = tabBar.selectedItem else { return }
        
        guard let index = items.firstIndex(of: selectedItem) else { return }
        
        let tabWidth = tabBar.bounds.width / CGFloat(items.count)
        
        let centerX = tabWidth * (CGFloat(index) + 0.5)
        
        indicatorView.backgroundColor = accentColor
        
        indicatorCenterXConstraint?.constant = centerX
        
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                self.tabBar.layoutIfNeeded()
            })
        } else {
            tabBar.layoutIfNeeded()
        }
    }
    
    private func animateTabSelection() {
        UIView.animate(withDuration: 0.15, animations: {
            self.indicatorView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }, completion: { _ in
            UIView.animate(withDuration: 0.15) {
                self.indicatorView.transform = .identity
            }
        })
    }
}

// MARK: - UITabBarControllerDelegate
extension ModernTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        updateSelectionIndicator()
        animateTabSelection()
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}