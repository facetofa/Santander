//
//  SceneDelegate.swift
//  Santander
//
//  Created by Serena on 21/06/2022
//


import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let subPathsVC: SubPathsTableViewController
        let window = UIWindow(windowScene: windowScene)
        if UIDevice.current.userInterfaceIdiom == .pad {
            let splitVC = UISplitViewController(style: .doubleColumn)
            let vc = PathListsSplitViewController(contents: [], title: "Santander")
            subPathsVC = vc
            splitVC.setViewController(vc, for: .primary)
            window.rootViewController = splitVC
        } else {
            let vc = SubPathsTableViewController(style: .userPreferred, path: .root)
            subPathsVC = vc
            window.rootViewController = UINavigationController(rootViewController: vc)
        }
        
        DispatchQueue.main.async {
            window.tintColor = UserPreferences.appTintColor.uiColor
            window.overrideUserInterfaceStyle = UIUserInterfaceStyle(rawValue: UserPreferences.preferredInterfaceStyle) ?? .unspecified
        }
        
        (window.rootViewController as? UISplitViewController)?.show(.primary) // Needed on iPad so that the SplitViewController displays no matter orientation
        self.window = window
        
        if let launchPath = UserPreferences.launchPath {
            subPathsVC.goToPath(path: URL(fileURLWithPath: launchPath))
        }
        
        window.makeKeyAndVisible()
        // handle incoming URLs
        self.scene(scene, openURLContexts: connectionOptions.urlContexts)
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    
    // Path is being imported
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        let urls = URLContexts.map(\.url)
        guard !urls.isEmpty else {
            return
        }
        
        let operationsVC = PathOperationViewController(paths: urls, operationType: .import)
        self.window?.rootViewController?.present(UINavigationController(rootViewController: operationsVC), animated: true)
    }
}

