//
//  AudioRecorder.swift
//  LearningAVFoundation
//

import Foundation
import AVFoundation
import SwiftUI

class LAudioManager: NSObject, ObservableObject {
    static let sharedInstance: LAudioManager = LAudioManager()
    public var audioEngine: AVAudioEngine?
	@Published var pitchShift = AVAudioUnitTimePitch()
	@Published var reverb = AVAudioUnitEQ()
    
    public var recorderStateMachine: LRecorderStateMachine? = nil
	
	override init() {
		super.init()
        LAudioData.sharedInstance.loadFileNames()
        audioEngine = LAudioData.sharedInstance.audioEngine
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	func prepareEngine() {
        guard let audioEngine = audioEngine else {
            return
        }
		let format = audioEngine.outputNode.inputFormat(forBus: 0) // Something is fishy
		print(format.sampleRate)
		print(AVAudioSession.sharedInstance().sampleRate)
        audioEngine.attach(LAudioPlayer.sharedInstance.audioEnginePlayer)
		audioEngine.attach(pitchShift)
		audioEngine.attach(reverb)
		audioEngine.connect(LAudioPlayer.sharedInstance.audioEnginePlayer, to: pitchShift, format: format)
		audioEngine.connect(pitchShift, to: reverb, format: format)
        audioEngine.connect(reverb, to: audioEngine.outputNode, format: format)


		pitchShift.pitch = 0.0

		audioEngine.prepare()
		print("AudioEngine is prepare to start")
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
    
	func playFile(named name: String) {
        LAudioRecorder.sharedInstance.stop()
        let temp = LAudioData.sharedInstance.previousRecordingUrl
        LAudioData.sharedInstance.previousRecordingUrl = LAudioData.sharedInstance.documentFolderUrl.appendingPathComponent(name, isDirectory: false)
        LAudioPlayer.sharedInstance.play()
        LAudioData.sharedInstance.previousRecordingUrl = temp
	}
	
	func deleteFile(at offsets: IndexSet) {
		if let indexToDelete = offsets.min() {
            let filename = LAudioData.sharedInstance.recordedFileNames[indexToDelete]
			print("Deleting: ", filename)
            let url = LAudioData.sharedInstance.documentFolderUrl.appendingPathComponent(filename, isDirectory: false)
			try? FileManager.default.removeItem(at: url)
		}
        LAudioData.sharedInstance.loadFileNames()
	}
	
}

