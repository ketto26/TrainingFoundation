//
//  AppDelegate.swift
//  BroadcastAppState
//
//  Created by Keto Nioradze on 29.07.25.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    //var window: UIWindow? // Required for non-SceneDelegate apps, or for older iOS versions
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        setupAppLifecycleObservers()
        
        return true
    }
    
    // MARK: - App Lifecycle Observation Methods
    private func setupAppLifecycleObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appDidEnterBackground),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appWillEnterForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
        print("DEBUG: App lifecycle observers set up.")
    }
    
    @objc func appDidEnterBackground() {
        print("APP STATE: Application entered background.")
    }
    
    @objc func appWillEnterForeground() {
        print("APP STATE: Application will enter foreground.")
    }
    
    // MARK: - Observer Removal
    private func removeAppLifecycleObservers() {
        NotificationCenter.default.removeObserver(self,
                                                  name: UIApplication.didEnterBackgroundNotification,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: UIApplication.willEnterForegroundNotification,
                                                  object: nil)
        print("DEBUG: App lifecycle observers removed.")
    }
    
    // MARK: - Core Application Delegate Methods
    func applicationWillTerminate(_ application: UIApplication) {
        removeAppLifecycleObservers()
        print("APP STATE: Application will terminate.")
    }
    
    deinit {
        print("DEBUG: AppDelegate deinit called. Ensuring observers are removed.")
        removeAppLifecycleObservers()
    }
    
    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
}
