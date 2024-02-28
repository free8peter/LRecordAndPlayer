//
//  LAudioRecorder.swift
//  Simple Recorder
//
//  Created by Zhang Jian on 2024/2/28.
//

import UIKit
import Foundation
import AVFoundation

class LAudioRecorder: NSObject {
    public static let sharedInstance = LAudioRecorder()
    
//    public var audioEngine = AVAudioEngine()
    var audioRecorder: AVAudioRecorder?
    var updateTimer: CADisplayLink?
    
    var recordTime: TimeInterval = 0.0
    var playbackTime: TimeInterval = 0.0
    public var audioEngine: AVAudioEngine?
    
    
    override init() {
        super.init()
        audioEngine = LAudioData.sharedInstance.audioEngine
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(handleRouteChange), name: AVAudioSession.routeChangeNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(handleInteruption), name: AVAudioSession.interruptionNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(handleAEChange), name: .AVAudioEngineConfigurationChange, object: nil)
    }
    func setupRecorder() {
        let settings: [String: Any] = [
            AVFormatIDKey : Int(kAudioFormatLinearPCM),
            AVSampleRateKey : 44100.0,
            AVNumberOfChannelsKey : 1,
            AVEncoderAudioQualityKey : AVAudioQuality.high.rawValue
        ]
        do {
            try audioRecorder = AVAudioRecorder(url: generateFileUrl(), settings: settings)
            audioRecorder?.delegate = self
        } catch {
            print("Error creating audio recorder with format: \(error.localizedDescription)")
        }
    }
    
    func record() {
        LAudioConfig.startRecordConfig()
        setupRecorder()
        
        if let recorder = audioRecorder {
            recorder.record()
        }
//        let recordMachine: LRecorderStateMachine? = LAudioManager.sharedInstance.recorderStateMachine
//        if let machine = recordMachine {
//            machine.recorderStateChange()
//        }
        
        let recordMachine: LRecorderStateMachine? = LAudioManager.sharedInstance.recorderStateMachine
        if let machine = recordMachine {
            machine.startToRecordEvent()
        }
        
        
        startUpdateLoop()
        print("record(): ", LAudioData.sharedInstance.audioEngine.isRunning)
        LSpeechTranscriptor.sharedInstance.startTranscript()
    }
    
    func stop() {
        if let recorder = audioRecorder {
            recorder.stop()
            
        }
        // todo peter
//        LAudioData.sharedInstance.recordingStatus = .stopped
        stopLoop()
        print("stop(): ", LAudioData.sharedInstance.audioEngine.isRunning)
        LSpeechTranscriptor.sharedInstance.endTranscript()
    }
    
    func startUpdateLoop() {
        if let updateTimer = updateTimer {
            updateTimer.invalidate()
        }
        updateTimer = CADisplayLink(target: self, selector: #selector(updateLoop))
        updateTimer?.add(to: .current, forMode: .common)
    }
    
    @objc func updateLoop() {
        // todo peter
//        DispatchQueue.main.async() { [self] in
//            if LAudioData.sharedInstance.recordingStatus == .recording {
//                if CFAbsoluteTimeGetCurrent() - self.recordTime > 0.5 {
//    //                print(audioRecorder?.currentTime)
//                    LAudioData.sharedInstance.time = self.formatTime(UInt(self.audioRecorder?.currentTime ?? 0))
//                    recordTime = CFAbsoluteTimeGetCurrent()
//                }
//            } else if LAudioData.sharedInstance.recordingStatus == .playing {
//                if CFAbsoluteTimeGetCurrent() - playbackTime > 0.5 {
//    //                print(audioEnginePlayer.lastRenderTime?.audioTimeStamp.mHostTime)
//                    
//                    // 注释player
////                    time = formatTime(UInt(audioPlayer?.currentTime ?? 0))
////                    playbackTime = CFAbsoluteTimeGetCurrent()
//                }
//            }
//        }
    }
    
    func stopLoop() {
        updateTimer?.invalidate()
        updateTimer = nil
        LAudioData.sharedInstance.time = "00:00:00"
    }
    
    private func formatTime(_ time: UInt) -> String {
        let hour = time / 3600
        let minute = (time / 60) % 60
        let seconds = time % 60
        
        return String(format: "%02i:%02i:%02i", hour, minute, seconds)
    }
    
    private func generateFileUrl() -> URL {
        var url = LAudioData.sharedInstance.previousRecordingUrl ?? LAudioData.sharedInstance.documentFolderUrl
        
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory,
                                                                   in: .userDomainMask,
                                                                   appropriateFor: nil,
                                                                   create: false)
            let formatter = DateFormatter()
            formatter.dateFormat = "MM-dd-yyyy_HH-mm-ss"
            
            let time = formatter.string(from: Date())
            let fileNameToSaved = "Recording_" + time + ".caf"
            url = documentDirectory.appendingPathComponent(fileNameToSaved, isDirectory: false)
            LAudioData.sharedInstance.previousRecordingFileName = fileNameToSaved
            print(url)
        } catch {
            print(error.localizedDescription)
        }
        
        LAudioData.sharedInstance.previousRecordingUrl = url
        
        return url
    }
    
    @objc func handleRouteChange(notification: Notification) {
        if let info = notification.userInfo,
           let rawValue = info[AVAudioSessionRouteChangeReasonKey] as? UInt {
            let reason = AVAudioSession.RouteChangeReason(rawValue: rawValue)
            if reason == .oldDeviceUnavailable {
                guard let previousRoute = info[AVAudioSessionRouteChangePreviousRouteKey] as? AVAudioSessionRouteDescription,
                      let previousOutput = previousRoute.outputs.first else {
                          return
                      }
                if previousOutput.portType == .headphones {
                    // todo peter
//                    if LAudioData.sharedInstance.recordingStatus == .playing {
////                        stopPlayback()
//                    } else if LAudioData.sharedInstance.recordingStatus == .recording {
//                        stop()
//                    }
                }
            }
        }
    }
    
    @objc func handleInteruption(notification: Notification) {
        if let info = notification.userInfo,
           let rawValue = info[AVAudioSessionInterruptionTypeKey] as? UInt {
            let type = AVAudioSession.InterruptionType(rawValue: rawValue)
            if type == .began {
                let recordMachine: LRecorderStateMachine? = LAudioManager.sharedInstance.recorderStateMachine
                if let machine = recordMachine {
                    machine.recorderInterruptEvent()
                }
            } else {
                if let rawValue = info[AVAudioSessionInterruptionOptionKey] as? UInt {
                    let options = AVAudioSession.InterruptionOptions(rawValue: rawValue)
                    if options == .shouldResume {
                        // restart audio or restart recording
                    }
                }
            }
        }
    }
    @objc func handleAEChange(notification: Notification) {
        if let info = notification.userInfo {
            print(info)
        }
    }
    
}

extension LAudioRecorder: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        
        let recordMachine: LRecorderStateMachine? = LAudioManager.sharedInstance.recorderStateMachine
        if let machine = recordMachine {
            machine.finishToRecordEvent()
        }
        
        LAudioData.sharedInstance.loadFileNames()
        
        // 录制完成后保存内容
        LDataManager.shareInstane.saveItem(
            LAudioData.sharedInstance.previousRecordingFileName ?? "",
            LAudioData.sharedInstance.outputText,
            LAudioData.sharedInstance.previousRecordingUrl?.absoluteString ?? "")
    }
}

