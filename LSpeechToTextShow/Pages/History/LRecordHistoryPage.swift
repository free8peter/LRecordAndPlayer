//
//  LRecordHistoryPage.swift
//  LSpeechToTextShow
//
//  Created by Zhang Jian on 2024/2/28.
//

import UIKit

// 录音历史界面
public class LRecordHistoryPage: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    private let allItems: NSMutableArray = NSMutableArray()
    let cellNibName = "LHistoryTableViewCell"
    let cellIdentifier = "LHistoryTableViewCellIdentifier"
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        allItems.removeAllObjects()
        LDataManager.shareInstane.readLocalFile()
        for each in LDataManager.shareInstane.allDataArray {
            allItems.add(each)
        }
        self.tableView.register(LHistoryTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    // 返回
    @IBAction func goBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // datasource delegate function
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dic: NSDictionary = allItems[indexPath.row] as! NSDictionary
        let cell: LHistoryTableViewCell? = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? LHistoryTableViewCell
        guard let cell = cell else {
            return LHistoryTableViewCell()
        }
        cell.dataIndex = indexPath.row
        
        let title: String? = dic[LDataManager.LDataManagerFileNameKey] as? String
        if let title = title {
            cell.textLabel?.text = title
            cell.dataIndex = indexPath.row
            
            cell.toCheckText = {(index) in
                self.goToRecordTextPage(index)
            }
        }
        
        return cell
    }
    
    private func goToRecordTextPage(_ index: Int) {
        let tempStory: UIStoryboard? = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let story = tempStory else {
            return
        }
        
        let tempDesPage: LRecordTextPage? = story.instantiateViewController(withIdentifier: "LRecordTextPage") as? LRecordTextPage
        if let desPage: LRecordTextPage = tempDesPage {
            desPage.index = index
            self.navigationController?.pushViewController(desPage, animated: true)
        }
    }
    
    // datasource delegate function
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allItems.count
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let dic: NSDictionary = allItems[indexPath.row] as! NSDictionary
        let title: String? = dic[LDataManager.LDataManagerFileNameKey] as? String
        if let title = title {
            LAudioManager.sharedInstance.playFile(named: title)
        }
    }
}
