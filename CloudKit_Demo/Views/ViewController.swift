//
//  ViewController.swift
//  CloudKit_Demo
//
//  Created by Mac on 2020/4/8.
//  Copyright © 2020 Mac. All rights reserved.
//

import UIKit
import CloudKit
import Kingfisher

class ViewController: BaseViewController {
    
    var btn : UIButton?
    var imgView = UIImageView()
    var tableView = UITableView()
    var Records : Array<CKRecord> = []
    var refresh = UIRefreshControl()
    
    ///查询数据的标记
    var cursor : CKQueryOperation.Cursor?
    var RecordIDs :Array<CKRecord.ID> = []
    var isloadAll = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setUI()
        //查询数据
        self.QuaryData()
        NotificationCenter.default.addObserver(self, selector: #selector(QuaryData), name: NSNotification.Name(UpdataBlogNotification), object: nil)
    
    }
    
    deinit {
        ///注销通知
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let userDefault = UserDefaults.standard
        
        if userDefault.value(forKey: "userName") == nil {
            let vc = LoginViewController()
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: false, completion: nil)
        }
        
    }
    
    private func setUI() {
        self.tableView = UITableView(frame: CGRect(origin: CGPoint(x: 0, y: self.navigationController!.navigationBar.frame.height+UIApplication.shared.statusBarFrame.height), size: CGSize(width: self.view.frame.width, height: self.view.frame.height - (self.navigationController!.navigationBar.frame.height+UIApplication.shared.statusBarFrame.height) - self.tabBarController!.tabBar.frame.height)))
        self.tableView.backgroundColor = UIColor.dynamicColor(lightColor: .white, darkColor: .black)
        self.tableView.register(MainTableViewCell.self, forCellReuseIdentifier: "MainCell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.showsVerticalScrollIndicator = false
        
        self.tableView.addSubview(self.refresh)
        self.refresh.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        
        view.addSubview(self.tableView)
        
        
        
    }
    
    @objc
    func QuaryData(){
        
        var operation : CKQueryOperation?
        
        if cursor != nil {
            operation = CKQueryOperation(cursor: cursor!)
        }else {
            let query = CKQuery(recordType: "BlogData", predicate: NSPredicate(value: true))
            ///添加排序条件，此方法会作用于后面用于更新的CKCursor
            query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            
            
            operation = CKQueryOperation(query: query)
        }
        
        operation?.resultsLimit = 5
        
        
        operation?.recordFetchedBlock = {record in
            
            if self.RecordIDs.contains(record.recordID) {
//                self.isloadAll = true
                print("查找完毕", self.isloadAll)
//               return
            }
            self.Records.append(record)
            self.RecordIDs.append(record.recordID)
            print("查询", record)
        }
        
        let publicDatabase = CKContainer.default().publicCloudDatabase
        
        ///此时才开始获取数据
//        if !self.isloadAll {
            publicDatabase.add(operation!)
//        }
        
        operation?.queryCompletionBlock = { (Cursor, e) in
            if e == nil {
                self.cursor = Cursor
                DispatchQueue.main.async {
                    print("数据量", self.Records.count)
                    self.tableView.reloadData()
                }
            }else {
                print("加载出错", e.debugDescription)
            }
        }
        
        
        
        //
    }
    
    @objc func refreshData() {
        self.Records = []
        var operation : CKQueryOperation?
        
        operation = CKQueryOperation(query: CKQuery.init(recordType: "BlogData", predicate: NSPredicate.init(value: true)))
        
        operation?.resultsLimit = 1
        
        
        
        operation?.recordFetchedBlock = {record in
            self.Records.insert(record, at: 0)
            print("查询", record)
        }
        operation?.queryCompletionBlock = { (Cursor, e) in
            if e == nil {
                self.cursor = Cursor
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.refresh.endRefreshing()
                }
            }else {
                print("加载出错")
            }
        }
        let publicDatabase = CKContainer.default().publicCloudDatabase
        
        ///此时才开始获取数据
        publicDatabase.add(operation!)
        //
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.Records.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MainCell" ,for: indexPath)  as! MainTableViewCell
        
        cell.record = self.Records[indexPath.row]
        cell.desLabelHeight = getLabHeigh(labelStr: cell.record?["des"] as! String)
        cell.nameLab?.text = cell.record!["Artist"] as? String
        cell.desLabel!.text = cell.record!["des"] as? String
        cell.desLabel!.frame = CGRect(origin: CGPoint(x: 10, y: 30), size: CGSize(width: cell.frame.width - 20, height: cell.desLabelHeight ?? 30))
        cell.imageScroller.frame = CGRect(origin: CGPoint(x: 0, y: 30 + (cell.desLabelHeight ?? 30)), size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width))
        cell.imageScroller.snp.makeConstraints { (make) in
            make.bottomMargin.equalToSuperview().offset(-30)
            make.size.equalTo(UIScreen.main.bounds.width)
        }
        for view in cell.imageScroller.subviews {
            view.removeFromSuperview()
        }
        if cell.record["images"] != nil {
            cell.imageScroller.contentSize = CGSize(width: UIScreen.main.bounds.width * CGFloat((cell.record!["images"] as! Array<CKAsset>).count), height: UIScreen.main.bounds.width)
            cell.loadImage()
        }else {
//            cell.imageScroller.removeFromSuperview()
            
        }
        
    
        
        cell.timeLab?.frame = CGRect(origin: CGPoint(x: 20, y: 35 + (cell.desLabelHeight ?? 30 ) + UIScreen.main.bounds.width), size: CGSize(width: cell.frame.width, height: 20))
        cell.timeLab?.text = cell.record?.creationDate?.description
        
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.Records.count == 0 {
            return 100
        }else {
            let record = self.Records[indexPath.row]
            if record["images"] == nil {
                return 40 + getLabHeigh(labelStr: record["des"] as! String)
            }else {
                return self.view.frame.width + 65 + getLabHeigh(labelStr: record["des"] as! String)
            }
            
        }
        
    }
    
    func getLabHeigh(labelStr:String) -> CGFloat {
        let lines = Int(CGFloat(labelStr.count) * 15 / (self.view.frame.width - 20) ) + 1
        return CGFloat((lines * 15) + 20)
        
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == self.Records.count - 1{
            DispatchQueue.main.async {
                self.QuaryData()
            }
            
        }
    }
}


