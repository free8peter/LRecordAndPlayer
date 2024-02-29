//
//  LAudioPlayer.swift
//  Simple Recorder
//
//  Created by Zhang Jian on 2024/2/28.
//

import UIKit
import Foundation
import AVFoundation
import SwiftUI

/**
 AudioPlayer,负责播放录音
 */
class LAudioPlayer: NSObject {
    public static let sharedInstance: LAudioPlayer = LAudioPlayer()
    
    
    var audioEnginePlayer = AVAudioPlayerNode()
    var speechSynthesizer = AVSpeechSynthesizer()
    @Published var speechPitch: Float = 1.0
    @Published var speechRate: Float = AVSpeechUtteranceDefaultSpeechRate
    @Published var playFromSpeechSynthesizer = false
    var textToSpeak: String = "Hello there"
    var audioPlayer: AVAudioPlayer?
    public var audioEngine: AVAudioEngine?
    
    
    override init() {
        super.init()
        speechSynthesizer.delegate = self
        audioEngine = LAudioData.sharedInstance.audioEngine
    }
    
    func play() {
        guard let audioEngine = audioEngine else {
            return
        }
        LAudioConfig.startPlayConfig()
        if playFromSpeechSynthesizer {
            let utterance = AVSpeechUtterance(string: textToSpeak)
            utterance.voice = AVSpeechSynthesisVoice(language: "en-AU")
            utterance.pitchMultiplier = speechPitch
            utterance.rate = speechRate
            
            speechSynthesizer.speak(utterance)
            
        } else {
            do {
                LAudioData.sharedInstance.fileToPlay = try AVAudioFile(forReading: LAudioData.sharedInstance.previousRecordingUrl!)
            } catch {
                print("Error Loading Audio File as AVAudioFile")
            }
            
            guard  LAudioData.sharedInstance.fileToPlay != nil else { return }
            audioEnginePlayer.scheduleFile(LAudioData.sharedInstance.fileToPlay!, at: nil, completionHandler: nil)
            
            
            
            do {
                try audioPlayer = AVAudioPlayer(contentsOf: LAudioData.sharedInstance.previousRecordingUrl!)
                audioPlayer?.delegate = self
            } catch {
                print("Error loading audio file from temp directory")
            }
            
            guard audioPlayer != nil else { return }
            if audioPlayer!.duration > 0 {
                audioPlayer!.volume = 0.8
                audioPlayer!.prepareToPlay()
            }
            
            startEngine()
            print("play() 2. Engine running? ", audioEngine.isRunning)
            
            guard audioEngine.isRunning else { return }
            
            audioPlayer!.play()
            audioEnginePlayer.play()
            // todo
//            recordingStatus = .playing
//            startUpdateLoop()
        }
    }
    
    func startEngine() {
        guard let audioEngine = audioEngine else {
            return
        }
        do {
            try audioEngine.start()
            print("Audio Engine prepared and running: ", audioEngine.isRunning)
        } catch {
            print("AudioEngine start failed: ", error.localizedDescription)
        }
    }
    
    func stopPlayback() {
        audioPlayer?.stop()
        audioEnginePlayer.stop()
        speechSynthesizer.stopSpeaking(at: .immediate)
        // todo peter
//        LAudioData.sharedInstance.recordingStatus = .stopped
//        stopLoop()
    }
    
    

}

// todo 不需要这个
extension LAudioPlayer: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        // todo peter
//        LAudioData.sharedInstance.recordingStatus = .playingSpeech
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        // todo peter
//        LAudioData.sharedInstance.recordingStatus = .stopped
    }
}

extension LAudioPlayer: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("Audio Player finished playing")
        // todo peter
//        LAudioData.sharedInstance.recordingStatus = .stopped
    }

}

