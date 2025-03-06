import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)

        // Decide which view controller should be shown on launch.
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
            // User is returning and logged in, so go to main tab bar.
            window?.rootViewController = createTabBarController()
        }

        window?.makeKeyAndVisible()
    }

    func createTabBarController() -> UITabBarController {
        // 1) Replace the direct ConnectionsGameViewController with MiniGamesViewController
        let miniGamesVC = MiniGamesViewController()
        miniGamesVC.tabBarItem = UITabBarItem(
            title: "Mini Games",
            image: UIImage(systemName: "gamecontroller"),
            tag: 0
        )

        // 2) Set up the other tabs
        let resourcesVC = ResourcesViewController()
        resourcesVC.tabBarItem = UITabBarItem(
            title: "Resources",
            image: UIImage(systemName: "book"),
            tag: 1
        )

        let leaderboardVC = LeaderboardViewController()
        leaderboardVC.tabBarItem = UITabBarItem(
            title: "Leaderboard",
            image: UIImage(systemName: "list.number"),
            tag: 2
        )

        let profileVC = ProfileViewController()
        profileVC.tabBarItem = UITabBarItem(
            title: "Profile",
            image: UIImage(systemName: "person.crop.circle"),
            tag: 3
        )

        // 3) Embed each in a UINavigationController if desired
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [
            UINavigationController(rootViewController: miniGamesVC),
            UINavigationController(rootViewController: resourcesVC),
            UINavigationController(rootViewController: leaderboardVC),
            UINavigationController(rootViewController: profileVC)
        ]
        
        // Set the highlighted (selected) tab color to light green.
        tabBarController.tabBar.tintColor = UIColor(red: 144/255, green: 238/255, blue: 144/255, alpha: 1)

        return tabBarController
    }


    private func isFirstLaunch() -> Bool {
        let hasLaunchedBefore = UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
        if !hasLaunchedBefore {
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
        }
        return !hasLaunchedBefore
    }

    private func isLoggedIn() -> Bool {
        // Replace with real authentication check
        return UserDefaults.standard.bool(forKey: "isLoggedIn") == true
    }

    // The following methods can remain as-is or as needed.
    func sceneDidDisconnect(_ scene: UIScene) { }
    func sceneDidBecomeActive(_ scene: UIScene) { }
    func sceneWillResignActive(_ scene: UIScene) { }
    func sceneWillEnterForeground(_ scene: UIScene) { }
    func sceneDidEnterBackground(_ scene: UIScene) { }
}
