//
//  LAudioRecognition.swift
//  Simple Recorder
//
//  Created by BetterPeter on 2024/2/28.
//

import UIKit
import Speech

class LSpeechTranscriptor: NSObject {
    static let sharedInstance = LSpeechTranscriptor()
    
    var audioTranscriptEngine = AVAudioEngine()
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private let authStat = SFSpeechRecognizer.authorizationStatus()
    private var recognitionTask: SFSpeechRecognitionTask?
    
    func startTranscript() {
        LAudioData.sharedInstance.outputText = "";
        let audioSession = AVAudioSession.sharedInstance()
        let inputNode = audioTranscriptEngine.inputNode
        
        do{
            try audioSession.setCategory(.record, mode: .spokenAudio, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        }catch{
            print("ERROR: - Audio Session Failed!")
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioTranscriptEngine.prepare()
        
        do{
            try audioTranscriptEngine.start()
        }catch{
            print("ERROR: - Audio Engine failed to start")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to create a SFSpeechAudioBufferRecognitionRequest object") }
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest){ result, error in
            if result != nil {
                if let result = result{
                    LAudioData.sharedInstance.outputText = result.bestTranscription.formattedString
                    // 借用了 recorder的状态机，触发更新文本事件
                    let statusTemp: LRecorderState? = LAudioManager.sharedInstance.recorderStateMachine?.currentState
                    if let status = statusTemp {
                        if (status == .START || status == .DURING_RECORDING) {
                            let recordMachine: LRecorderStateMachine? = LAudioManager.sharedInstance.recorderStateMachine
                            if let machine = recordMachine {
                                machine.inRecordingEvent()
                            }
                        }
                    }
                }
                if error != nil {
                    // Stop recognizing speech if there is a problem.
                    self.audioTranscriptEngine.stop()
                    inputNode.removeTap(onBus: 0)
                    self.recognitionRequest = nil
                    self.recognitionTask = nil
                    
                }
            }
        }
    }
    
    func endTranscript() {
        self.audioTranscriptEngine.stop()
        recognitionRequest?.endAudio()
//        self.audioTranscriptEngine.inputNode.removeTap(onBus: 0)
        self.recognitionTask?.cancel()
        self.recognitionTask = nil
    }

}
