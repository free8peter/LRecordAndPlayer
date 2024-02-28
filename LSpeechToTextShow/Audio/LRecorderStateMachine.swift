//
//  LRecorderStateMachine.swift
//  LSpeechToTextShow
//
//  Created by Zhang Jian on 2024/2/28.
//

import UIKit

enum LRecorderState {
    case INIT // 初始状态
    case START // 开始录音
    case RECORDING // 录音中
    case FINISH // 完成录音
    case RESUME // 中断可以恢复的状态
    case CANOT_CRESUME // 中断后无法恢复
    case INTERRRUPT // 录音中断，可能由于各种原因引起,比如电话，或者其他应用获取录音权限
    case TO_TEXT_ERROR_OCCUR // 转文本发生错误
    case APP_EXIT // app退出, 这个情况暂时不需要处理，但是可以作为后续日志等用处，或发生异常后用户再次打开录音状态的恢复
}

// 录音状态回调函数
typealias LRecorderStateChange = (_ beforeState : LRecorderState, _ currentState: LRecorderState, _ needUpdateUI: Bool) -> Void

/**
 录音状态机
 状态的改变由录音的各种事件触发
 状态改变后会触发回调函数
 可以在回调函数中刷新UI或其他操作
 */
class LRecorderStateMachine: NSObject {
    public var currentState: LRecorderState = .INIT
    public var recorderStateChange: LRecorderStateChange
    init(currentState: LRecorderState, recorderStateChange: @escaping LRecorderStateChange) {
        self.currentState = currentState
        self.recorderStateChange = recorderStateChange
        // 首次需要刷新UI，因为传入true,最后一个参数
        recorderStateChange(.INIT, self.currentState, true)
    }
    
    // 恢复初始状态事件
    func resumeInitStateEvent() {
        let stateBefore: LRecorderState = currentState;
        currentState = .INIT
        recorderStateChange(stateBefore, currentState, stateBefore == currentState)
    }
    
    // 开始录音事件
    func startToRecordEvent() {
        changeRecordState(.START)
    }
    
    // 录音中事件
    func inRecordingEvent() {
        changeRecordState(.RECORDING)
    }
    
    // 完成录音事件
    func finishToRecordEvent() {
        changeRecordState(.FINISH)
    }
    
    // 转为文本发生错误事件
    func toTextErrorOccurEvent() {
        changeRecordState(.TO_TEXT_ERROR_OCCUR)
    }
    
    // 录音被打断，可能由于电话或者其他，再次进入app可以有恢复录音的操作
    func recorderInterruptEvent() {
        changeRecordState(.INTERRRUPT)
    }
    
    // 中断后录音恢复
    func recorderResumeEvent() {
        changeRecordState(.RESUME)
    }
    
    // 中断后录音无法恢复
    func recorderCanNotResumeEvent() {
        changeRecordState(.CANOT_CRESUME)
    }
    
    // 改变状态，并触发回调函数
    private func changeRecordState(_ state: LRecorderState) {
        let stateBefore: LRecorderState = currentState;
        currentState = state
        recorderStateChange(stateBefore, currentState, stateBefore != currentState)
    }
}
