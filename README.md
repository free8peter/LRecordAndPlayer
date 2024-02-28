# About ME
## 1.本程序主要实现了：
###   a.录音；
###   b.录音的同时记录文本；
###   c.录音的同时记录音频；
###   d.保存并持久化上述b和c的内容；
###   e.回放录音功能；
###   f.查看录音转换的文本的内容
###   g.本地通知，录音中断，通知用户

## 2.页面结构
###   a.首页(LHomePage)，主要功能为录制音频和页面导航功能；
###   b.查看历史记录页面(LRecordHistoryPage)，可以选择cell回放录音，也可以点击查看转换的文本
###   c.查看录音页面(LRecordTextPage)，转换的文本页面；

## 3.录音和播放代码架构
###   a.主要使用了状态机：具体有LRecorderStateMachine（录音状态机）和LPlayerStateMachine(播放状态机)
####     (1). Why？考虑到录音过程中情况较为复杂，比如录音中途可能会遇到用户点击录音完成、暂停、还有系统挂断等等操作，部分操作是不可预知的，因此如果使用常规的做法，比如在录音的类LAudioPlayer中加入各种回调，会导致代码臃肿，同时也会使得使用该工具的页面逻辑复杂，后续可能会造成难以维护。
####     (2).How?实现录音的Controller只需要跟进录音状态处理各种情况即可；  

## 4.录音相关类简单介绍：
###   a.LPlayerStateMachine 回放录音状态机；
###   b.LRecorderStateMachine 录音状态机
###   c.LAudioManager 音频管理器；
###   d.LAudioPlayer 音频播放器；
###   e.LAudioRecorder 音频录制器；
###   f.LSpeechTranscriptor 录音中的文本识别器；

## 5.录音相关api:
###   a.开始录音:LAudioRecorder.sharedInstance.record()
###   b.结束录音:LAudioRecorder.sharedInstance.stop()
###   c.状态机设置回调函数, 中间content部分为回调结果,beforeState，状态机之前状态，currentState，状态机现在状态，needUpdateUI，是否刷新UI（needUpdateUi状态改变时为true，否则为false）
        let recorderMachine: LRecorderStateMachine = LRecorderStateMachine.init(currentState: .INIT) { beforeState, currentState, needUpdateUI in
            // content
        }
        LAudioManager.sharedInstance.recorderStateMachine = recorderMachine

## 5.TODO
###   a.因为时间有限，本工程一些代码可以进一步优化；
###   b.部分代码在一些情况下，可能有Bug，需要进一步解决；

## peter zhang
