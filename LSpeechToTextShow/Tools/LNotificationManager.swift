//
//  LNotificationManager.swift
//  LSpeechToTextShow
//
//  Created by Zhang Jian on 2024/2/28.
//

import UIKit
import UserNotifications

class LNotificationManager: NSObject {
    public static func requestLocalNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            if granted {
                print("权限已授权")
            } else if let error = error {
                print("请求授权失败: \(error.localizedDescription)")
            }
        }
    }
    
    // 创建一个通知内容
    private static func createNotificationContent() -> UNNotificationContent {
        //设置推送内容
        let content = UNMutableNotificationContent()
        content.title = "LRecorder录音中断"
        content.body = "点击唤醒App重新开始录音"
        content.sound = UNNotificationSound.default
        return content
    }
    
    // 创建一个触发通知的时间
    private static func createNotificationTrigger() -> UNTimeIntervalNotificationTrigger {
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        return trigger
    }
    
    // 通知用户音频录制中断
    public static func notifyUserAudioRecordInterrupted() {
        let content = createNotificationContent()
        let trigger = createNotificationTrigger()
        
        let request = UNNotificationRequest(identifier: "com.hx.gogogo", content: content, trigger: trigger)
        
        let center = UNUserNotificationCenter.current()
        center.add(request, withCompletionHandler: { (error) in
            if let error = error {
                print("添加通知请求失败: \(error.localizedDescription)")
            } else {
                print("通知已安排")
            }
        })
    }
}
