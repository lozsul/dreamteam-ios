//
//  AppDelegate.swift
//  DreamTeam
//
//  Created by Lauren Sullivan on 3/23/21.
//

import Foundation
import UserNotifications
import UIKit

enum Identifiers {
  static let completeAction = "COMPLETE_IDENTIFIER"
  static let taskCategory = "TASK_CATEGORY"
}

// Need AppDelegate for Push Notifications
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    // Initialising the application
    func application(_ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        UITabBar.appearance().barTintColor = UIColor.green
        UITabBar.appearance().tintColor = UIColor.white

        registerForPushNotifications()
        return true
    }
    
    // Process incoming remote notifications
    func application(_ application: UIApplication,
    didReceiveRemoteNotification userInfo: [AnyHashable: Any],
    fetchCompletionHandler completionHandler:
    @escaping (UIBackgroundFetchResult) -> Void
    ) {
        guard let aps = userInfo["aps"] as? [String: AnyObject] else {
            completionHandler(.failed)
            return
        }
        application.applicationIconBadgeNumber = aps["badge"] as! Int
    }
  
    // Register to receive remote notifications through Apple Push Notification service
    func registerForPushNotifications() {
        
        UNUserNotificationCenter.current()
        
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]
            ) {
                [weak self] granted, _ in
                guard granted else { return }
                
                let completeAction = UNNotificationAction(
                identifier: Identifiers.completeAction,
                title: "View",
                options: [.foreground])

                let taskCategory = UNNotificationCategory(
                identifier: Identifiers.taskCategory,
                actions: [completeAction],
                intentIdentifiers: [],
                options: [])

                UNUserNotificationCenter.current().setNotificationCategories([taskCategory])

                self?.getNotificationSettings()
            }
    }
  
    // Requests the notification settings for this app
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
  
    // Tells the delegate that the app successfully registered with Apple Push Notification service (APNs)
    func application(_ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        _ = tokenParts.joined()
    }
}

// UNUserNotificationCenterDelegate: The interface for handling incoming notifications and notification-related actions
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        _ = response.notification.request.content.userInfo
    }
}
