//
//  ViewController.swift
//  LSpeechToText
//
//  Created by Zhang Jian on 2024/2/26.
//

import UIKit

/**
 首页Controller
 */
class LHomePage: UIViewController {
    
    var audioManager = LAudioManager.sharedInstance
    
    // 用户提示录音状态的label
    @IBOutlet weak var tipLabel: UILabel!
    // 操作button
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    
    let startRecordText = "开始录音"
    let endRecordText = "结束录音"
    let textViewTipText = "录音开始后，这里将同步展示录音文本内容。"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        LPermissChecker.requestAudioRecordPermisson()
        let result: Bool = LPermissChecker.checkAudioRecordAvalibility();
        if (result == false) {
            // 弹出请在设置权限中打开麦克风的提示
        }
        
        audioManager.prepareEngine()
        addAudioRecorderStateMachine()
        
        LNotificationManager.requestLocalNotificationPermission()
    }
    
    // 根据目前录音状态设置action button 标题，只有开始和录音中两种情况才设置结束录音，其他都是开始录音
    @IBAction func recordButtonClicked(_ sender: Any) {
        if (currentRecordState() == .START
            || currentRecordState() == .DURING_RECORDING) {
            // 触发结束录音事件
            LAudioRecorder.sharedInstance.stop();
        } else {
            // 开始录音
            LAudioRecorder.sharedInstance.record()
        }
    }
    
    
    private func addAudioRecorderStateMachine() {
        let recorderMachine: LRecorderStateMachine = LRecorderStateMachine.init(currentState: .INIT) { beforeState, currentState, stateChanged in
            self.recordStateDidChange(currentState, stateChanged)
        }
        LAudioManager.sharedInstance.recorderStateMachine = recorderMachine
    }
    
    // 打开录音历史页
    @IBAction func toHistoryPage(_ sender: Any) {
        let tempStory: UIStoryboard? = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let story = tempStory else {
            return
        }
        
        let tempDesPage: LRecordHistoryPage? = story.instantiateViewController(withIdentifier: "LRecordHistoryPage") as? LRecordHistoryPage
        if let desPage: LRecordHistoryPage = tempDesPage {
            self.navigationController?.pushViewController(desPage, animated: true)
        }
    }
    
    // 依据目前的状态更新UI
    func recordStateDidChange(_ state: LRecorderState, _ stateChanged: Bool) {
        switch state {
        case .INIT:
            handleRecordStateChangeWhenInit(state, stateChanged)
        case .START:
            handleRecordStateChangeWhenStart(state, stateChanged)
        case .DURING_RECORDING:
            handleRecordStateChangeWhenRecording(state, stateChanged)
        case .FINISH:
            handleRecordStateChangeWhenFinish(state, stateChanged)
        case .INTERRRUPT:
            handleRecordStateChangeWhenInterrupt(state, stateChanged)
        case .TO_TEXT_ERROR_OCCUR:
            handleRecordStateChangeWhenTextErrorOccur(state, stateChanged)
        case .APP_EXIT:
            handleRecordStateChangeWhenAppExit(state, stateChanged)
        case .RESUME:
            handleRecordStateChangeWhenResume(state, stateChanged)
        case .CANOT_CRESUME:
            handleRecordStateChangeWhenCannotAutoResume(state, stateChanged)
        }
    }
    
    // 录音初始化UI
    func handleRecordStateChangeWhenInit(_ state: LRecorderState, _ stateChanged: Bool) {
        if (stateChanged) {
            actionButtonTextChangeToNormal()
            self.textView.text = textViewTipText
        }
    }
    // 录音开始，可执行一些开始动画等
    func handleRecordStateChangeWhenStart(_ state: LRecorderState, _ stateChanged: Bool) {
        if (stateChanged) {
            self.actionButton.setTitle(endRecordText, for: .normal)
            self.tipLabel.text = "录音中"
        }
    }
    // 录音中，用于同步输出文本
    func handleRecordStateChangeWhenRecording(_ state: LRecorderState, _ stateChanged: Bool) {
        self.textView.text = LAudioData.sharedInstance.outputText
    }
    // 录音结束
    func handleRecordStateChangeWhenFinish(_ state: LRecorderState, _ stateChanged: Bool) {
        actionButtonTextChangeToNormal()
        self.textView.text = textViewTipText
    }
    // 录音被打断，可以执行部分恢复操作
    func handleRecordStateChangeWhenInterrupt(_ state: LRecorderState, _ stateChanged: Bool) {
        actionButtonTextChangeToNormal()
        // 发出通知告知用户
        LNotificationManager.notifyUserAudioRecordInterrupted()
    }
    // 录音过程中Text识别发生错误，需要弹出alert重新开始录音
    func handleRecordStateChangeWhenTextErrorOccur(_ state: LRecorderState, _ stateChanged: Bool) {
        actionButtonTextChangeToNormal()
    }
    // 录音中，程序退出，可以结束录音，或者打Log用于分析程序等。
    func handleRecordStateChangeWhenAppExit(_ state: LRecorderState, _ stateChanged: Bool) {
        // pass
    }
    
    // 打断后又开始恢复录音
    func handleRecordStateChangeWhenResume(_ state: LRecorderState, _ stateChanged: Bool) {
        // pass
    }
    
    // 打断后又无法进行恢复
    func handleRecordStateChangeWhenCannotAutoResume(_ state: LRecorderState, _ stateChanged: Bool) {
        // pass
    }
    
    // 将Button改为Normal时候的title及颜色等
    func actionButtonTextChangeToNormal() {
        self.actionButton.setTitle(startRecordText, for: .normal)
        self.tipLabel.text = ""
    }
    
    // 获取状态机目前最新的状态
    private func currentRecordState() -> (LRecorderState) {
        let state: LRecorderState = .INIT
        let machine: LRecorderStateMachine? = LAudioManager.sharedInstance.recorderStateMachine
        if let machine: LRecorderStateMachine = machine {
            return machine.currentState
        }
        return state
    }

}

