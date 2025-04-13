//
//  PushNotificationManager.swift
//  EventSplit
//
//  Created by Yasas Hansaka Thenuwara on 2025-04-12.
//
import UserNotifications
import UIKit

class PushNotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = PushNotificationManager()
    
    override private init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                completion(granted)
            }
            
            if let error = error {
                print("Push Notification Authorization Error:", error)
            }
        }
    }
    
    func scheduleNotification(
        title: String,
        body: String,
        timeInterval: TimeInterval? = nil,
        date: Date? = nil
    ) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let trigger: UNNotificationTrigger
        
        if let timeInterval = timeInterval {
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        } else if let date = date {
            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
            trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        } else {
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        }
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification:", error)
            }
        }
    }

        func scheduleNotificationWithNavigation(
        title: String,
        body: String,
        type: String,
        referenceId: String,
        timeInterval: TimeInterval? = nil,
        date: Date? = nil
    ) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.userInfo = [
            "type": type,
            "referenceId": referenceId
        ]
        
        let trigger: UNNotificationTrigger
        
        if let timeInterval = timeInterval {
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        } else if let date = date {
            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
            trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        } else {
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        }
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification:", error)
            }
        }
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        
        if let type = userInfo["type"] as? String,
           let referenceId = userInfo["referenceId"] as? String {
            NotificationCenter.default.post(
                name: Notification.Name("NotificationTapped"),
                object: nil,
                userInfo: [
                    "type": type,
                    "referenceId": referenceId
                ]
            )
        } else {
            print("PushNotificationManager.userNotificationCenter: Missing notification data")
        }
        completionHandler()
    }
}