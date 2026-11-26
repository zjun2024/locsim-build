import UIKit

// MARK: - LowBar: alert helpers used by the LocSim screens
//
// Andromeda routes these through AlertKit. The trimmed build keeps the same call
// sites but implements them with plain UIKit, so no alert framework is needed.

func lowBarTopController() -> UIViewController? {
    let scenes = UIApplication.shared.connectedScenes
    let scene = scenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
        ?? scenes.compactMap { $0 as? UIWindowScene }.first
    guard let window = scene?.windows.first(where: { $0.isKeyWindow }) ?? scene?.windows.first else {
        return nil
    }
    var top = window.rootViewController
    while let presented = top?.presentedViewController {
        top = presented
    }
    return top
}

func lowBarPresent(_ alert: UIAlertController, animated: Bool = true) {
    DispatchQueue.main.async {
        lowBarTopController()?.present(alert, animated: animated)
    }
}

// MARK: - UIApplication conveniences

extension UIApplication {
    func dismissAlert(animated: Bool) {
        DispatchQueue.main.async {
            lowBarTopController()?.dismiss(animated: animated)
        }
    }

    func alert(title: String = "Error", body: String, animated: Bool = true, withButton: Bool = true) {
        let ac = UIAlertController(title: title, message: body, preferredStyle: .alert)
        if withButton {
            ac.addAction(UIAlertAction(title: "OK", style: .cancel))
        }
        lowBarPresent(ac, animated: animated)
    }

    func confirmAlert(
        title: String = "Error",
        body: String,
        onOK: @escaping () -> Void,
        noCancel: Bool,
        onCancel: (() -> Void)? = nil,
        yes: Bool = false
    ) {
        let ac = UIAlertController(title: title, message: body, preferredStyle: .alert)
        if !noCancel {
            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
                onCancel?()
            })
        }
        ac.addAction(UIAlertAction(title: yes ? "Yes" : "OK", style: noCancel ? .cancel : .default) { _ in
            onOK()
        })
        lowBarPresent(ac)
    }

    func textFieldAlert(
        title: String,
        message: String? = nil,
        textFieldPlaceholder: String,
        secondTextFieldPlaceholder: String? = nil,
        completion: @escaping (String?, String?) -> Void
    ) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addTextField { field in
            field.placeholder = textFieldPlaceholder
        }
        if let second = secondTextFieldPlaceholder {
            ac.addTextField { field in
                field.placeholder = second
            }
        }
        ac.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            let first = ac.textFields?.first?.text
            let second = secondTextFieldPlaceholder != nil ? ac.textFields?[1].text : nil
            completion(first, second)
        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        lowBarPresent(ac)
    }

    func respringDeprecated() {
        // The trimmed build never resprings; it only installs and moves its own
        // simulated location.
    }
}
