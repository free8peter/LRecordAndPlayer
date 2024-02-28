//
//  LHistoryTableViewCell.swift
//  LSpeechToTextShow
//
//  Created by Zhang Jian on 2024/2/28.
//

import UIKit



typealias LRecordTextDetailSelected = (_ index : Int) -> Void

/**
 录音历史Cell
 */
class LHistoryTableViewCell: UITableViewCell {
    // cell的index
    var dataIndex: Int?
    // 用户点击录音查看
    var toCheckText: LRecordTextDetailSelected?
    // 查看textButton
    var button: UIButton?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    // 初始化方法
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 查看文本
    @objc public func toDetailPage(_ sender: UIButton) {
        guard let toCheck = toCheckText,
                let theIndex = dataIndex else {
            return
        }
        toCheck(theIndex)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.textLabel?.font = UIFont.systemFont(ofSize: 13)
        if (button == nil) {
            button = UIButton(frame: CGRectZero)
            if let theButton = button {
                theButton.addTarget(self, action: #selector(toDetailPage(_:)), for: .touchUpInside)
                theButton.setTitle("查看文本", for: .normal)
                self.addSubview(theButton)
                theButton.frame = CGRect(x: 260, y: 0, width: 100, height: 50)
                theButton.backgroundColor = UIColor.gray
            }
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
}
