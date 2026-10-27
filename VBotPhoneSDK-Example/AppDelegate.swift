//
//  AppDelegate.swift
//  VBotPhoneSDK-Example
//
//  Created by VPMedia on 22/1/26.
//

import UIKit
import Intents
import PushKit
import VBotPhoneSDK

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    var voipRegistry: PKPushRegistry!

    class var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }

    var notificationCenter: UNUserNotificationCenter {
        return UNUserNotificationCenter.current()
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = ViewController()
        window?.makeKeyAndVisible()

        // Cấu hình cho SDK
        let config = VBotConfig(
            supportPopupCall: true, // Bật popup call trong cuộc gọi
            includesCallsInRecents: true,
            iconTemplateImageData: UIImage(named: "callkit-icon")?.pngData(), // Icon cho màn hình CallKit
            environment: .staging
        )
        
        // Khởi tạo SDK
        VBotPhone.sharedInstance.setup(with: config)
        VBotPhone.sharedInstance.addDelegate(self)
        
        // Khởi tạo PKPushRegistry
        voipRegistry = PKPushRegistry(queue: .main)
        voipRegistry!.desiredPushTypes = [.voIP]
        voipRegistry!.delegate = self

        return true
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        switch userActivity.activityType {
        case "INStartAudioCallIntent":
            return handleStartCallIntent(
                INStartAudioCallIntent.self,
                userActivity: userActivity,
                contacts: \.contacts
            )

        case "INStartCallIntent":
            if #available(iOS 13.0, *) {
                return handleStartCallIntent(
                    INStartCallIntent.self,
                    userActivity: userActivity,
                    contacts: \.contacts
                )
            } else {
                return false
            }

        default:
            return false
        }
    }

    private func handleStartCallIntent<T: INIntent>(
        _ intentType: T.Type,
        userActivity: NSUserActivity,
        contacts: KeyPath<T, [INPerson]?>
    ) -> Bool {
        let intent = userActivity.interaction?.intent
        guard let intent = intent as? T else {
            return false
        }
        
        if let person = intent[keyPath: contacts]?.first {
            let displayName = person.displayName
            _ = VBotPhone.sharedInstance.getCallIntentFromUserActivity(displayName)
        }
       
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {}
    func applicationDidEnterBackground(_ application: UIApplication) {}
    func applicationWillEnterForeground(_ application: UIApplication) {}
    func applicationDidBecomeActive(_ application: UIApplication) {}
    func applicationWillTerminate(_ application: UIApplication) {}
}

// Lắng nghe các sự kiện của Pushkit
extension AppDelegate: PKPushRegistryDelegate {
    nonisolated func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        guard let token = registry.pushToken(for: .voIP) else {
            return
        }

        let pushToken = token.map { String(format: "%.2hhx", $0) }.joined()
        DispatchQueue.main.async {
            savePushToken(pushToken)
        }
    }

    nonisolated func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        if type == .voIP {
            VBotPhone.sharedInstance.startIncomingCall(
                payload: payload,
                completion: completion
            )
        } else {
            completion()
        }
    }

    nonisolated func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {}
}

extension AppDelegate: VBotPhoneDelegate {
    nonisolated func receivedApnsToken(token: String?) {}
    nonisolated func callInfoUpdated() {}
    nonisolated func callStarted() {}
    nonisolated func callAccepted() {}
    nonisolated func callEnded(reason: VBotEndCallReason, endedBy: VBotCallEndParty) {
        print("callEnded: reason=\(reason.key), endedBy=\(endedBy.key)")
    }
    nonisolated func callMuteStateDidChange(muted: Bool) {}
    nonisolated func callHoldStateDidChange(isOnHold: Bool) {}
    nonisolated func callStateChanged(state: VBotCallState) {}

    @objc func showCallVC(_ notification: Notification? = nil) {}

    @objc func hideCallVC(_ notification: Notification? = nil) {
        DispatchQueue.main.async {
            AppDelegate.shared.window?.rootViewController?.dismissViewControllerFromVisibleViewController()
        }
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
