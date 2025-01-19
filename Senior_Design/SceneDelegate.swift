import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        window = UIWindow(windowScene: windowScene)

        // Determine the initial view controller
        if isFirstLaunch() {
            let onboardingVC = OnboardingViewController()
            let navigationController = UINavigationController(rootViewController: onboardingVC)
            window?.rootViewController = navigationController
        } else if !isLoggedIn() {
            let loginVC = LoginViewController()
            let navigationController = UINavigationController(rootViewController: loginVC)
            window?.rootViewController = navigationController
        } else {
            window?.rootViewController = createTabBarController()
        }

        window?.makeKeyAndVisible()
    }

    func createTabBarController() -> UITabBarController {
        let minigameVC = ConnectionsGameViewController()
        minigameVC.tabBarItem = UITabBarItem(title: "Minigame", image: UIImage(systemName: "gamecontroller"), tag: 0)

        let resourcesVC = ResourcesViewController()
        resourcesVC.tabBarItem = UITabBarItem(title: "Resources", image: UIImage(systemName: "book"), tag: 1)

        let leaderboardVC = LeaderboardViewController()
        leaderboardVC.tabBarItem = UITabBarItem(title: "Leaderboard", image: UIImage(systemName: "list.number"), tag: 2)

        let profileVC = ProfileViewController()
        profileVC.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person.crop.circle"), tag: 3)

        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [
            UINavigationController(rootViewController: minigameVC),
            UINavigationController(rootViewController: resourcesVC),
            UINavigationController(rootViewController: leaderboardVC),
            UINavigationController(rootViewController: profileVC)
        ]
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
        return UserDefaults.standard.bool(forKey: "isLoggedIn") == true
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
    }
}
