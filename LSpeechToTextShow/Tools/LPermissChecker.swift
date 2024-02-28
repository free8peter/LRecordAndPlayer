//
//  LPermissChecker.swift
//  LSpeechToText
//
//  Created by Zhang Jian on 2024/2/26.
//

import UIKit
import AVFoundation

/**
 用于检测权限的类
 */
class LPermissChecker: NSObject {
    /**
     请求录音权限
     - 首次运行系统会弹出请求提示
     - 后续运行
     1.启动会使用checkAudioRecordAvalibility来检测录音权限；
     2.点击开始录音会检查录音权限如果没有录音权限；
     那么引导用户打开录音权限
     */
    public static func requestAudioRecordPermisson() {
        let permissionStatus = AVAudioSession.sharedInstance().recordPermission
        if permissionStatus == AVAudioSession.RecordPermission.undetermined {
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                // pass
                
            }
        }
    }
    
    /**
     检测音频录制是否可用
     - return YES: 可用
     - return NO: 不可用
     */
    static func checkAudioRecordAvalibility() -> Bool {
        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.audio)
        return authStatus != .restricted
        && authStatus != .denied
        && authStatus != .notDetermined
    }
}
