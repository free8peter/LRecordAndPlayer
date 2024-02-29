//
//  LPlayerStateMachine.swift
//  LSpeechToTextShow
//
//  Created by Zhang Jian on 2024/2/28.
//

import UIKit

// 播放的状态
enum LPlayerState {
    case INIT // 初始状态，启动后为这个状态，设置player状态为NONE
    case START // 当前为播放音频时，player状态为PLAY
    case PLAYING // 播放中
    case STOP // 播放音频用户暂停为STORY
    case FINISH // 播放音频完成，player状态为FINISH
    case ERROR // 当前播放音频发生错误，状态为ERROR
}

// 播放状态发生改变
typealias LPlayerStateChange = (_ beforeState : LPlayerState, _ currentState: LPlayerState, _ stateChanged: Bool) -> Void

/**
 播放状态状态机
 
 */
class LPlayerStateMachine: NSObject {
    // 当前的播放状态
    private var currentState: LPlayerState = .INIT
    // 播放状态发生改变
    public var playerStateChange: LPlayerStateChange
    
    // 初始化
    init(currentState: LPlayerState, stateChange: @escaping LPlayerStateChange) {
        self.currentState = currentState
        self.playerStateChange = stateChange
        // 首次需要刷新UI，因为传入true,最后一个参数
        playerStateChange(.INIT, self.currentState, true)
    }
    
    /**
      恢复初始状态，用于录音或者录音期间
     */
    func resumeToInitStateEvent() {
        var stateBefore: LPlayerState = currentState;
        currentState = .INIT
        playerStateChange(stateBefore, currentState, stateBefore == currentState)
    }
    
    // 开始播放事件
    func playerStartEvent() {
        changePlayerState(.START)
    }
    
    // 开始播放事件
    func playerDuringPlayingEvent() {
        changePlayerState(.PLAYING)
    }
    
    // 结束播放事件
    func playerFinishEvent() {
        changePlayerState(.FINISH)
    }
    
    // 播放发生错误事件
    func playerOccurErrorEvent() {
        changePlayerState(.ERROR)
    }
    
    // 改变播放器状态
    private func changePlayerState(_ state: LPlayerState) {
        let stateBefore: LPlayerState = currentState;
        currentState = state
        playerStateChange(stateBefore, currentState, stateBefore == currentState)
    }
}
