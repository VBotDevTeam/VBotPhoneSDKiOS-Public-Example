//
//  Helpers.swift
//  VBotPhoneSDK_Example
//
//  Created by VPMedia on 31/7/25.
//

import Foundation
import UIKit

// MARK: - UIColor Compatibility

extension UIColor {
    static var systemMintCompat: UIColor {
        if #available(iOS 15.0, *) {
            return .systemGreen
        } else {
            return .systemBlue
        }
    }

    static var systemTealCompat: UIColor {
        if #available(iOS 15.0, *) {
            return .systemGreen
        } else {
            return .systemGreen
        }
    }
}

extension UIViewController {
    @objc open func wrapToNavigationController() -> SPNavigationController {
        let navigationController = SPNavigationController(rootViewController: self)
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

open class SPNavigationController: UINavigationController {
    // MARK: - Init

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

    /**
     SparrowKit: Wrapper of init.
     Called in each init and using for configuration.

     No need ovveride init. Using one function for configurate view.
     */
    open func commonInit() {}

    // MARK: - Layout

    /**
     SparrowKit: If set to `true`, navigation bar apply horizontal margins from view of navigation controller.
     Default is `false`.
     */
    open var inheritLayoutMarginsForNavigationBar: Bool = false

    /**
     SparrowKit: If set to `true`, child controllers apply horizontal margins from view of navigation controller.
     Default is `false`.
     */
    open var inheritLayoutMarginsForСhilds: Bool = false

    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Inhert of Navigation Bar

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

        // Inhert childs controllers

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
