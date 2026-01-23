//
//  AppDelegate.swift
//  VBotPhoneSDK-Example
//
//  Created by DAT NGUYEN QUOC on 22/1/26.
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
            iconTemplateImageData: UIImage(named: "callkit-icon")?.pngData() // Icon cho màn hình CallKit
        )
        // Khởi tạo SDK
       
        
        VBotPhone.sharedInstance.setup(with: config)
        // VBotPhone.sharedInstance.addDelegate(self)
        
        // Khởi tạo PKPushRegistry
        voipRegistry = PKPushRegistry(queue: .main)
        voipRegistry!.desiredPushTypes = [.voIP]
        voipRegistry!.delegate = self

        return true
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        VBotLogger.info(filter: "🍭 AppDelegate URL", "continue userActivity \(userActivity.activityType)")

        switch userActivity.activityType {
        case "INStartAudioCallIntent":
            return handleStartCallIntent(
                INStartAudioCallIntent.self,
                userActivity: userActivity,
                contacts: \.contacts,
            )

        case "INStartCallIntent":
            if #available(iOS 13.0, *) {
                return handleStartCallIntent(
                    INStartCallIntent.self,
                    userActivity: userActivity,
                    contacts: \.contacts,
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
        contacts: KeyPath<T, [INPerson]?>,
    ) -> Bool {
        let intent = userActivity.interaction?.intent
        
        dump(intent)
        guard let intent = intent as? T else {
            return false
        }
        
        if let person =  intent[keyPath: contacts]?.first {
            let displayName = person.displayName
            
            let result = VBotPhone.sharedInstance.getCallIntentFromUserActivity(displayName)
            dump(result)
        }
       
        return true
    }
    
    

    func applicationWillResignActive(_ application: UIApplication) {}

    func applicationDidEnterBackground(_ application: UIApplication) {}

    func applicationWillEnterForeground(_ application: UIApplication) {}

    func applicationDidBecomeActive(_ application: UIApplication) {}

    func applicationWillTerminate(_ application: UIApplication) {
    }
}

// Lắng nghe các sự kiện cùa Pushkit
extension AppDelegate: PKPushRegistryDelegate {
    nonisolated func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        guard let token = registry.pushToken(for: .voIP) else {
            VBotLogger.error(filter: "🍭 AppDelegate", "Không thể lấy token push")
            return
        }

        let pushToken = token.map { String(format: "%.2hhx", $0) }.joined()
        
        DispatchQueue.main.async {
            savePushToken(pushToken)
        }
        
        VBotLogger.debug(filter: "🍭 AppDelegate", "Nhận được token: \(pushToken)")
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

    nonisolated func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        VBotLogger.error(filter: "🍭 AppDelegate", "didInvalidatePushTokenFor \(type)")
    }
}

