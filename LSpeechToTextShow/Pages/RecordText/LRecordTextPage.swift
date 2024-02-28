//
//  LHistoryDetailPage.swift
//  LSpeechToTextShow
//
//  Created by Zhang Jian on 2024/2/29.
//

import UIKit



class LRecordTextPage: UIViewController {
    
    var index: Int?

    @IBOutlet weak var textView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.white
        
        let array: NSMutableArray = LDataManager.shareInstane.allDataArray
        if let theIndex = index, array.count > theIndex {
            let dic: NSDictionary = array[theIndex] as! NSDictionary
            let textContent: String? = dic[LDataManager.LDataManagerFileTranscriptContentKey] as? String
            
            self.textView.text = textContent
        }
    }
    
    @IBAction func goBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

}
