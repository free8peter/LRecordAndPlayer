//
//  LAudioData.swift
//  Simple Recorder
//
//  Created by Zhang Jian on 2024/2/28.
//

import UIKit
import Foundation
import AVFoundation

class LAudioData: NSObject {
    static let sharedInstance: LAudioData = LAudioData()
    public var audioEngine = AVAudioEngine()
    @Published var recordedFileNames: [String] = []
//    @Published var recordingStatus: RecordingState = .stopped
    var previousRecordingUrl: URL?
    var previousRecordingFileName: String?
    @Published var time = "00:00:00"
    var fileToPlay: AVAudioFile?
    
    var currentIndex: Int = 0
    
    public var outputText:String = "";
    
    public func loadFileNames() {
        do {
            recordedFileNames = try FileManager.default.contentsOfDirectory(atPath: documentFolderUrl.path).filter { $0.hasSuffix(".caf") }
            print("Loaded: ", recordedFileNames)
        } catch {
            print("Error loading document folder")
        }
    }
    
    var documentFolderUrl: URL {
        FileManager.default.urls(for: .documentDirectory,
                                 in: .userDomainMask)[0]
    }
    
}
