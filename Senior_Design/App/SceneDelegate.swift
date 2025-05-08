import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)

        let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")

        if !hasCompletedOnboarding {
            print("Onboarding not completed. Showing Onboarding.")
            let onboardingVC = OnboardingViewController()
            let nav = UINavigationController(rootViewController: onboardingVC)
            window?.rootViewController = nav
        } else {
            if AuthManager.shared.isLoggedIn {
                 print("User is logged in. Transitioning to main app.")
                 window?.rootViewController = createTabBarController()
            } else if AuthManager.shared.isGuest {
                 print("User is in guest mode. Transitioning to main app.")
                 window?.rootViewController = createTabBarController()
            } else {
                 print("User not logged in or guest. Transitioning to login.")
                 let loginVC = LoginViewController()
                 let nav = UINavigationController(rootViewController: loginVC)
                 window?.rootViewController = nav
            }
        }

        window?.makeKeyAndVisible()
    }

    func createTabBarController() -> UITabBarController {
        let tabBarController = ModernTabBarController()

        let accentColor = UIColor(red: 76/255, green: 187/255, blue: 123/255, alpha: 1.0)

        let miniGamesVC = MiniGamesViewController()
        let miniGamesNav = UINavigationController(rootViewController: miniGamesVC)
        miniGamesNav.tabBarItem = UITabBarItem(
            title: "Mini Games",
            image: UIImage(systemName: "gamecontroller"),
            tag: 0
        )

        let resourcesVC = ResourcesViewController()
        let resourcesNav = UINavigationController(rootViewController: resourcesVC)
        resourcesNav.tabBarItem = UITabBarItem(
            title: "Resources",
            image: UIImage(systemName: "book"),
            tag: 1
        )

        let leaderboardVC = LeaderboardViewController()
        let leaderboardNav = UINavigationController(rootViewController: leaderboardVC)
        leaderboardNav.tabBarItem = UITabBarItem(
            title: "Leaderboard",
            image: UIImage(systemName: "list.number"),
            tag: 2
        )

        let profileVC = ProfileViewController()
        let profileNav = UINavigationController(rootViewController: profileVC)
        profileNav.tabBarItem = UITabBarItem(
            title: "Profile",
            image: UIImage(systemName: "person.crop.circle"),
            tag: 3
        )

        tabBarController.viewControllers = [
            miniGamesNav,
            resourcesNav,
            leaderboardNav,
            profileNav
        ]

        tabBarController.tabBar.tintColor = accentColor
        tabBarController.tabBar.unselectedItemTintColor = UIColor.gray.withAlphaComponent(0.6)

        if let modernTBC = tabBarController as? ModernTabBarController {
             modernTBC.accentColor = accentColor
        }

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
        return !UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    }

    func navigateToLogin() {
        print("Navigating to Login Screen...")
        AuthManager.shared.logout()

        let loginVC = LoginViewController()
        let nav = UINavigationController(rootViewController: loginVC)

        DispatchQueue.main.async {
            if let window = self.window {
                window.rootViewController = nav
                UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil, completion: nil)
            } else {
                 print("Warning: SceneDelegate window was nil during navigateToLogin.")
                 self.window?.rootViewController = nav
                 self.window?.makeKeyAndVisible()
            }
        }
    }

    func presentLoginScreen(from viewController: UIViewController, completion: (() -> Void)? = nil) {
        print("Presenting Login Screen Modally...")
        let loginVC = LoginViewController()

        let nav = UINavigationController(rootViewController: loginVC)
        nav.modalPresentationStyle = .fullScreen
        if let sheet = nav.sheetPresentationController {
             sheet.detents = [.large()]
             sheet.prefersGrabberVisible = true
        }
        viewController.present(nav, animated: true, completion: completion)
    }


    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
    }
}

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
            indicatorView.widthAnchor.constraint(equalToConstant: 40)
        ])

        indicatorCenterXConstraint = indicatorView.centerXAnchor.constraint(equalTo: tabBar.leadingAnchor)
        indicatorCenterXConstraint?.isActive = true

        updateSelectionIndicator(animated: false)
    }

    private func updateSelectionIndicator(animated: Bool = true) {
        guard let items = tabBar.items, items.count > 0, let selectedItem = tabBar.selectedItem else {
             indicatorView.isHidden = true
             return
        }
        indicatorView.isHidden = false

        guard let index = items.firstIndex(of: selectedItem) else { return }

        let tabWidth = tabBar.bounds.width / CGFloat(items.count)
        let centerX = tabWidth * (CGFloat(index) + 0.5)

        indicatorView.backgroundColor = accentColor

        indicatorCenterXConstraint?.constant = centerX

        if animated {
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
                self.tabBar.layoutIfNeeded()
            })
        } else {
            tabBar.layoutIfNeeded()
        }
    }

    private func animateTabSelection() {
        UIView.animate(withDuration: 0.15, animations: {
            self.indicatorView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }, completion: { _ in
            UIView.animate(withDuration: 0.15) {
                self.indicatorView.transform = .identity
            }
        })
    }
}

extension ModernTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        updateSelectionIndicator()
        animateTabSelection()

        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}