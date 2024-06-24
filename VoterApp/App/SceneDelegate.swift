//
//  SceneDelegate.swift
//  VoterApp
//
//  Created by kacper.czapp on 04/03/2024.
//

import UIKit

import UIKit
import SwiftUI

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var screen: UIScreen?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else {
            return
        }
        let window = UIWindow(windowScene: windowScene)
        let windowSceneObject = WindowSceneObject(windowScene)

        if session.role == .windowExternalDisplayNonInteractive {
            let contentView = LeaderboardView()
                .modelContainer(DataStore.sharedModelContainer)
                .environmentObject(windowSceneObject)
            window.rootViewController = UIHostingController(rootView: contentView)
        } else {
            let contentView = ControlPanelView()
                .modelContainer(DataStore.sharedModelContainer)
                .environmentObject(windowSceneObject)
            window.rootViewController = UIHostingController(rootView: contentView)
        }
        self.window = window
        window.makeKeyAndVisible()
    }

    func windowScene(
        _ windowScene: UIWindowScene,
        didUpdate previousCoordinateSpace: UICoordinateSpace,
        interfaceOrientation previousInterfaceOrientation: UIInterfaceOrientation,
        traitCollection previousTraitCollection: UITraitCollection
    ) {
        setupDisplayLinkIfNecessary()
    }


    weak var linkedScreen: UIScreen?


    func setupDisplayLinkIfNecessary() {
        let currentScreen = self.screen
        if currentScreen != linkedScreen {
            self.linkedScreen = currentScreen
        }
    }

    func scene(
        _ scene: UIScene,
        openURLContexts urlContexts: Set<UIOpenURLContext>
    ) { }

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
}
