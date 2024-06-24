//
//  AppDelegate.swift
//  VoterApp
//
//  Created by kacper.czapp on 04/03/2024.
//

import Combine
import UIKit
import SwiftUI

@main
struct MyMain: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    @State var additionalWindows: [UIWindow] = []

    let dataStore = DataStore()

    private var screenDidConnectPublisher: AnyPublisher<UIScreen, Never> {
        NotificationCenter.default
            .publisher(for: UIScreen.didConnectNotification)
            .compactMap { $0.object as? UIScreen }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }

    private var screenDidDisconnectPublisher: AnyPublisher<UIScreen, Never> {
        NotificationCenter.default
            .publisher(for: UIScreen.didDisconnectNotification)
            .compactMap { $0.object as? UIScreen }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }

    var body: some Scene {
        WindowGroup {
            ControlPanelView()
                .modelContainer(DataStore.sharedModelContainer)
                .onReceive(
                    screenDidConnectPublisher,
                    perform: screenDidConnect
                )
                .onReceive(
                    screenDidDisconnectPublisher,
                    perform: screenDidDisconnect
                )
        }
    }

    private func screenDidConnect(_ screen: UIScreen) {
        let window = UIWindow(frame: screen.bounds)

        window.windowScene = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.screen == screen }

        let view = LeaderboardView().modelContext(.init(DataStore.sharedModelContainer))
        let controller = UIHostingController(rootView: view)
        window.rootViewController = controller
        window.isHidden = false
        additionalWindows.append(window)
    }

    private func screenDidDisconnect(_ screen: UIScreen) {
        additionalWindows.removeAll {
            $0.screen === screen
        }
    }

}

final class AppDelegate: UIResponder, UIApplicationDelegate, ObservableObject {
    @Published var isExternalScreenConnected = false

    let dataStore = DataStore()
    var externalWindow: UIWindow?
    var externalVC: UIViewController?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

//        NotificationCenter.default.addObserver(
//            forName: UIScreen.didDisconnectNotification,
//            object: nil,
//            queue: .main
//        ) { _ in
//            self.isExternalScreenConnected = false
//            self.externalVC = nil
//            self.externalWindow = nil
//        }
//
//        NotificationCenter.default.addObserver(
//            forName: UIScreen.didConnectNotification,
//            object: nil,
//            queue: .main
//        ) { object in
//            print("Connected \(object)")
//        }
        return true
    }

//    private func setupExternalScreen(
//        session: UISceneSession,
//        options: UIScene.ConnectionOptions
//    ) {
//        let newWindow = UIWindow()
//        let windowScene = UIWindowScene(session: session, connectionOptions: options)
//        newWindow.windowScene = windowScene
//        externalWindow = newWindow
//
//        let externalView = ExternalView().modelContainer(dataStore.sharedModelContainer)
//        let hostingController = UIHostingController(rootView: externalView)
//        newWindow.rootViewController = hostingController
//        newWindow.isHidden = false
//        externalVC = hostingController
//    }

    // MARK: UISceneSession Lifecycle

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let config: UISceneConfiguration = if connectingSceneSession.role == .windowExternalDisplayNonInteractive {
            .init(name: "External",
                  sessionRole: .windowExternalDisplayNonInteractive)
        } else {
            .init(name: "Default",
                  sessionRole: connectingSceneSession.role)
        }
        config.delegateClass = SceneDelegate.self
        return config
    }
}
