//
//  LAudioConfig.swift
//  Simple Recorder
//
//

import UIKit
import AVFoundation

class LAudioConfig: NSObject {
    public static func startPlayConfig() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, mode: .spokenAudio, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        }
        catch let error as NSError {
            print("ERROR:", error)
        }
    }
    
    public static func startRecordConfig() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        }
        catch let error as NSError {
            print("ERROR:", error)
        }
    }
}
