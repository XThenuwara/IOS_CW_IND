//
//  AppDelegate.swift
//  EventSplit
//
//  Created by Yasas Hansaka Thenuwara on 2025-04-12.
//
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    private var notificationTimer: Timer?
    private let notificationModel = NotificationCoreDataModel.shared
    private let pushNotificationManager = PushNotificationManager.shared

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        print("App launched")
        setupNotifications()
        return true
    }

     private func setupNotifications() {
        // Request push notification permission
        pushNotificationManager.requestAuthorization { granted in
            if granted {
                self.startNotificationFetching()
            }
        }
    }
    
    
    private func startNotificationFetching() {
        fetchAndNotify()
    
        // Timer 5 min
        notificationTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
            self?.fetchAndNotifyWithNavigation()
        }
    }

    private func fetchAndNotify() {
        notificationModel.fetchNotifications { notifications in
            for notification in notifications {
                self.pushNotificationManager.scheduleNotification(
                    title: notification.title ?? "New Notification",
                    body: notification.message ?? "",
                    timeInterval: 1
                )
                self.notificationModel.markAsRead(notification: notification)
            }
        }
    }
    
    // Notification with navigation
    private func fetchAndNotifyWithNavigation() {
        notificationModel.fetchNotifications { notifications in
            for notification in notifications {
                self.pushNotificationManager.scheduleNotificationWithNavigation(
                    title: notification.title ?? "New Notification",
                    body: notification.message ?? "",
                    type: notification.type ?? "",
                    referenceId: notification.reference_id ?? "",
                    timeInterval: 1
                )
                self.notificationModel.markAsRead(notification: notification)
            }
        }
    }
    
    deinit {
        notificationTimer?.invalidate()
    }
}
