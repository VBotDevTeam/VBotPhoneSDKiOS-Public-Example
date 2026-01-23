//
//  Helpers.swift
//  VBotPhoneSDK_Example
//
//  Created by VPMedia on 31/7/25.
//

import Foundation
import UIKit


extension UIViewController {
    @objc open func wrapToNavigationController() -> VPNavigationController {
        let navigationController = VPNavigationController(rootViewController: self)
        #if os(iOS)
        navigationController.navigationBar.prefersLargeTitles = false
        #endif
        return navigationController
    }

    func hideKeyboardWhenTappedAround() {
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    @objc func hideKeyboard() {
        view.endEditing(true)
    }
}

struct Res: Codable {
    let status: Int
    let error: String
    let message: String
}

open class VPNavigationController: UINavigationController {

    override public init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        commonInit()
    }

    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override public init(navigationBarClass: AnyClass?, toolbarClass: AnyClass?) {
        super.init(navigationBarClass: navigationBarClass, toolbarClass: toolbarClass)
    }

    open func commonInit() {}

    open var inheritLayoutMarginsForNavigationBar: Bool = false

    open var inheritLayoutMarginsForСhilds: Bool = false

    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()


        if inheritLayoutMarginsForNavigationBar {
            let leftMargin = view.layoutMargins.left
            let rightMargin = view.layoutMargins.left

            if navigationBar.layoutMargins.left != leftMargin {
                navigationBar.layoutMargins.left = leftMargin
            }
            if navigationBar.layoutMargins.right != rightMargin {
                navigationBar.layoutMargins.right = rightMargin
            }
        }


        if inheritLayoutMarginsForСhilds {
            let leftMargin = view.layoutMargins.left
            let rightMargin = view.layoutMargins.left

            for childController in viewControllers {
                if childController.view.layoutMargins.left != leftMargin {
                    childController.view.layoutMargins.left = leftMargin
                }
                if childController.view.layoutMargins.right != rightMargin {
                    childController.view.layoutMargins.right = rightMargin
                }
            }
        }
    }
}

class LoadingView: UIView {
    private let activityIndicator = UIActivityIndicatorView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        backgroundColor = .clear
        layer.cornerRadius = 10

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(activityIndicator)
        activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

        activityIndicator.startAnimating()
    }
}

extension UIViewController {
    func showProgress() {
        DispatchQueue.main.async {
            if let _ = self.view.viewWithTag(999) {
                return
            }

            let loadingView = LoadingView(frame: self.view.bounds)
            loadingView.tag = 999
            self.view.addSubview(loadingView)
        }
    }

    func hideProgress() {
        DispatchQueue.main.async {
            if let loadingView = self.view.viewWithTag(999) {
                loadingView.removeFromSuperview()
            }
        }
    }
    
    // MARK: - Alert Helpers
    
    func showError(code: Int, message: String) {
        let alert = UIAlertController(
            title: "Lỗi",
            message: "Code: \(code)\nMessage: \(message)",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Đóng", style: .default))
        present(alert, animated: true)
    }

    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}


enum AppEnvironment {
    case debug
    case testFlight
    case appStore
}

// MARK: - UITextFieldDelegate

extension ViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.isEmpty { return true }
        return string.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }
}



extension UIViewController {
    func presentViewControllerFromVisibleViewController(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
        if let navigationController = self as? UINavigationController {
            navigationController.topViewController?.presentViewControllerFromVisibleViewController(viewControllerToPresent, animated: flag, completion: completion)
        } else if let tabBarController = self as? UITabBarController {
            tabBarController.selectedViewController?.presentViewControllerFromVisibleViewController(viewControllerToPresent, animated: flag, completion: completion)
        } else if let presentedViewController = presentedViewController {
            presentedViewController.presentViewControllerFromVisibleViewController(viewControllerToPresent, animated: flag, completion: completion)
        } else {
            present(viewControllerToPresent, animated: flag, completion: completion)
        }
    }

    func dismissViewControllerFromVisibleViewController() {
        if let navigationController = self as? UINavigationController {
            navigationController.topViewController?.dismiss(animated: true)
        } else if let tabBarController = self as? UITabBarController {
            tabBarController.selectedViewController?.dismiss(animated: true)
        } else if let presentedViewController = presentedViewController {
            presentedViewController.dismiss(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
}
