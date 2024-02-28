//
//  LDataManager.swift
//  LSpeechToText
//
//  Created by Zhang Jian on 2024/2/26.
//

import UIKit

/**
 全局数据管理中心
 */
class LDataManager: NSObject {
    // 文件名key
    public static let LDataManagerFileNameKey = "LDataManagerFileNameKey"
    // 录音文件保存的文字的key
    public static let LDataManagerFileTranscriptContentKey = "FileTranscriptContentKey"
    public static let LDataManagerFileLocalUrlPathKey = "LDataManagerFileLocalUrlPathKey"
    public static let sharedInstance: LDataManager = LDataManager()
    
    let localFileName = "my_recorder_history.plist"
//    let fileNameKey = "LDataManagerFileNameKey"
    let allDataArray: NSMutableArray = NSMutableArray()
    static let shareInstane: LDataManager = LDataManager()
    
    // 读取本地文件
    public func readLocalFile() {
        if FileManager.default.fileExists(atPath: localFileSavePath()) {
            let tempArray: NSMutableArray? = NSMutableArray.init(contentsOfFile: localFileSavePath())
            if let dataArray = tempArray {
                allDataArray.removeAllObjects()
                for each in dataArray {
                    allDataArray.add(each)
                }
            }
        }
    }
    
    // 录制完成添加item
    private func addItemData(_ dic: NSDictionary) {
        readLocalFile()
        allDataArray.add(dic)
        saveToLocal()
    }
    
    // 保存到本地
    private func saveToLocal() {
        if (allDataArray.count == 0) {
            return
        }
        
        if FileManager.default.fileExists(atPath: localFileSavePath()) {
            do {
                try FileManager.default.removeItem(atPath: localFileSavePath())
            } catch {
                print("删除失败！")
            }
        }
        if !FileManager.default.fileExists(atPath: localFileSavePath()) {
            allDataArray.write(toFile: localFileSavePath(), atomically: true)
        }
    }
    
    //
    private func localFileSavePath() -> String {
        let docPath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.path
        let filePath = URL(fileURLWithPath: docPath).appendingPathComponent(localFileName).path
        return filePath
    }
    
    // 录音完成后，保存一个item
    public func saveItem(_ fileName: String,
                         _ fileTextContent: String,
                         _ fileUrlPathString: String) {
        if (!fileName.isEmpty
            && !fileTextContent.isEmpty
            && !fileUrlPathString.isEmpty) {
            let dic = NSMutableDictionary()
            dic.setObject(fileName, forKey: LDataManager.LDataManagerFileNameKey as NSCopying)
            dic.setObject(fileTextContent, forKey: LDataManager.LDataManagerFileTranscriptContentKey as NSCopying)
            dic.setObject(fileUrlPathString, forKey: LDataManager.LDataManagerFileLocalUrlPathKey as NSCopying)
            
            addItemData(dic)
        }
    }
}
