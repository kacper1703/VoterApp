//
//  WindowSceneObject.swift
//  VoterApp
//
//  Created by kacper.czapp on 04/03/2024.
//

import Combine
import UIKit

/// Wraps `UIWindowScene` as an `ObservableObject` to be passed to SwiftUI views.
final class WindowSceneObject: ObservableObject {
    @Published var windowScene: UIWindowScene?

    init(_ windowScene: UIWindowScene?) {
        self.windowScene = windowScene
    }
}
