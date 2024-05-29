//
//  Alert.swift
//  VoterApp
//
//  Created by kacper.czapp on 05/03/2024.
//

import UIKit

enum Alert {
    struct ButtonModel: Equatable, Hashable {

        static let ok = ButtonModel(title: "OK", style: .default)
        static let cancel = ButtonModel(title: "Cancel", style: .cancel)
        static let `continue` = ButtonModel(title: "Continue", style: .default)

        let title: String
        private(set) var style: UIAlertAction.Style
        
        var styledDestructive: Self { withUpdated(style: .destructive) }
        var styledCancel: Self { withUpdated(style: .cancel) }

        static func == (lhs: ButtonModel, rhs: ButtonModel) -> Bool {
            lhs.title == rhs.title
        }

        func withUpdated(style: UIAlertAction.Style) -> Self {
            var model = self
            model.style = style
            return model
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(title)
        }
    }

    struct Style {
        let messageAlignment: NSTextAlignment
    }

    typealias ButtonModels = [ButtonModel?]

    static func show(title: String?,
                     message: String?,
                     buttons: ButtonModels,
                     style: Style? = nil,
                     completion: ((ButtonModel?) -> Void)? = nil) {
        Task {
            let result = await showAsync(title: title, message: message, buttons: buttons, style: style)
            await MainActor.run { completion?(result) }
        }
    }

    @MainActor
    @discardableResult
    static func showAsync(title: String?,
                          message: String?,
                          buttons: ButtonModels,
                          style: Style? = nil) async -> ButtonModel? {
        let unwrappedButtons = buttons.compactMap { $0 }
        precondition(!unwrappedButtons.isEmpty, "Cannot show alert with no buttons!")
        precondition(!unwrappedButtons.hasDuplicates(by: \.title),
                     "Alert should not have duplicate buttons with the same titles! Got: \(unwrappedButtons.map(\.title))")

        let alert = ForceDismissableAlert(title: title, message: message, preferredStyle: .alert)

        if let style {
            alert.setMessageAlignment(style.messageAlignment)
        }

        if let topMostViewController = UIApplication.shared.topMostViewController as? ForceDismissableAlert {
            await topMostViewController.forceDismiss(animated: false)
        }

        return await withCheckedContinuation { continuation in
            unwrappedButtons.forEach { model in
                alert.addAction(.init(title: model.title, style: model.style) { _ in
                    continuation.resume(returning: model)
                })
            }
            alert.onForceDismiss {
                continuation.resume(returning: nil)
            }
            DispatchQueue.main.async {
                let topMostViewController = UIApplication.shared.topMostViewController
                topMostViewController?.view.window?.isUserInteractionEnabled = true
                topMostViewController?.present(alert, animated: true)
            }
        }
    }
}

public extension Sequence where Element: Hashable {
    func toSet() -> Set<Element> {
        Set(self)
    }

    func uniqued() -> [Element] {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }

    func unique<T: Hashable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        var set = Set<T>()
        return self.reduce(into: [Element]()) { result, value in
            guard !set.contains(value[keyPath: keyPath]) else {
                return
            }
            set.insert(value[keyPath: keyPath])
            result.append(value)
        }
    }
}

public extension Array where Element: Hashable {
    var hasDuplicates: Bool {
        toSet().count != self.count
    }

    func hasDuplicates<T: Hashable>(by keyPath: KeyPath<Element, T>) -> Bool {
        unique(by: keyPath).count != self.count
    }
}

private final class ForceDismissableAlert: UIAlertController {

    private(set) var onForceDismiss: (() -> Void)?

    func onForceDismiss(_ closure: @escaping (() -> Void)) {
        onForceDismiss = closure
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.tintColor = .accent
    }

    @MainActor
    func forceDismiss(animated: Bool) async {
        guard presentingViewController != nil else { return }

        await withCheckedContinuation { [weak self] (contin: CheckedContinuation<Void, Never>) in
            self?.presentingViewController?.dismiss(animated: animated) {
                self?.onForceDismiss?()
                contin.resume()
            }
        }
    }

    func setMessageAlignment(_ alignment: NSTextAlignment) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = alignment

        let messageText = NSMutableAttributedString(
            string: self.message ?? "",
            attributes: [
                NSAttributedString.Key.paragraphStyle: paragraphStyle,
                NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .footnote)
            ]
        )

        setValue(messageText, forKey: "attributedMessage")
    }
}

extension UIApplication {
    var topMostViewController: UIViewController? {
        let keyWindow = UIApplication.shared
            .connectedScenes
            .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
            .first { $0.isKeyWindow }
        guard let rootViewController = keyWindow?.rootViewController else {
            return nil
        }

        var topController = rootViewController
        while let presentedViewController = topController.presentedViewController,
              !presentedViewController.isBeingDismissed {
            topController = presentedViewController
        }
        return topController
    }
}
