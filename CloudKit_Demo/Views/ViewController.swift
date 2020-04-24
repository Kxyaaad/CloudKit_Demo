//
//  ViewController.swift
//  CloudKit_Demo
//
//  Created by Mac on 2020/4/8.
//  Copyright © 2020 Mac. All rights reserved.
//

import UIKit
import CloudKit

class ViewController: BaseViewController {

    var btn : UIButton?
    var imgView = UIImageView()
    var tableView = UITableView()
    var Records : Array<CKRecord> = []
    var refresh = UIRefreshControl()
    
    ///查询数据的标记
    var cursor : CKQueryOperation.Cursor?
    
    
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
        self.refresh.addTarget(self, action: #selector(QuaryData), for: .valueChanged)
        
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
                
        operation?.resultsLimit = 2
        
        operation?.queuePriority = .veryHigh
        
        operation?.recordFetchedBlock = {record in
            self.Records.append(record)
            print("查询", record)
        }


        operation?.queryCompletionBlock = { (Cursor, e) in
            if e == nil {
                self.cursor = Cursor
                DispatchQueue.main.async {
                    print("数据量", self.Records.count)
                    self.tableView.reloadData()
                    if self.refresh.isRefreshing {
                        self.refresh.endRefreshing()
                    }
                }
            }else {
                print("加载出错", e.debugDescription)
            }
        }
    
        let publicDatabase = CKContainer.default().publicCloudDatabase
   
        ///此时才开始获取数据
        publicDatabase.add(operation!)
//
//        publicDatabase.perform(CKQuery.init(recordType: "BlogData", predicate: NSPredicate.init(value: true)), inZoneWith: nil) { (records, error) in
//            if records != nil {
//                self.Records = records!
//                self.Records = self.Records.reversed()
//                DispatchQueue.main.async {
//                    self.tableView.reloadData()
//                    if self.refresh.isRefreshing {
//                        self.refresh.endRefreshing()
//                    }
//                }
//
//            }
//        }
    }
    
    @objc func refreshData() {
//        self.Records = []
        var operation : CKQueryOperation?
            
        operation = CKQueryOperation(query: CKQuery.init(recordType: "BlogData", predicate: NSPredicate.init(value: true)))
                    
        operation?.resultsLimit = 2
        
        
        
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
        cell.desLabelHeight = getLabHeigh(labelStr: cell.record!["des"] as! String)
        if cell.isLoad == false  {
            cell.setUI()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       
        let record = self.Records[indexPath.row]
        
        return self.view.frame.width + 65 + getLabHeigh(labelStr: record["des"] as! String)
    }
    
     func getLabHeigh(labelStr:String) -> CGFloat {
        let lines = Int(CGFloat(labelStr.count) * 15 / (self.view.frame.width - 20) ) + 1
        return CGFloat((lines * 15) + 20)

    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == self.Records.count - 1 {
            DispatchQueue.main.async {
                self.QuaryData()
            }
            
        }
    }
}

 
