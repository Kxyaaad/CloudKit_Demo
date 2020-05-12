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
import CoreData

class ViewController: BaseViewController, NSFetchedResultsControllerDelegate {
    
    var btn : UIButton?
    var imgView = UIImageView()
    var tableView = UITableView()
    var Records : Array<CKRecord> = []
    var refresh = UIRefreshControl()

    var isLoadAll = false //是否加载完最早的一条数据
    var RecordIDs : Array<CKRecord.ID> = []
    
    ///CloudKit + CoreData
    var fetchedResultsController: NSFetchedResultsController<BlogData>?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if UserDefaults.standard.value(forKey: "userName") != nil {
            readCoreData()
            self.setUI()
                
            if UserDefaults.standard.value(forKey: "cursor") != nil {
                self.refreshData()
            }else {
                self.QuaryData()
            }
        }
        
        
        
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
        //获取上次加载数据的节点
        let cursorData = UserDefaults.standard.value(forKey: "cursor")
        
        var operation : CKQueryOperation!
        
        if cursorData != nil {
            print("节点存在")
            let cursor = unArchiverCursor(data: cursorData as! Data)
            operation = CKQueryOperation(cursor: cursor)
        }else {
            let query = CKQuery(recordType: "BlogData", predicate: NSPredicate(value: true))
            ///添加排序条件，此方法会作用于后面用于更新的CKCursor
            query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            
            operation = CKQueryOperation(query: query)
        }
        
        operation?.resultsLimit = 1
        
        ///返回的每一条查询数据
        operation?.recordFetchedBlock = {record in
            if self.RecordIDs.contains(record.recordID){
                return
            }else {
                self.Records.append(record)
                self.RecordIDs.append(record.recordID)
            
                //保存到本地coreData
                CoreDataManager.saveCDRecords(record: record)
            }
        }
        
        let publicDatabase = CKContainer.default().publicCloudDatabase
        
        ///此时才开始获取数据
        publicDatabase.add(operation!)
        
        ///执行完所有获取操作
        operation?.queryCompletionBlock = { (Cursor, e) in
            if e == nil {
                ///保存浏览记录
                print("节点", Cursor)
                if Cursor != nil {
                    let saveCursor = archiverCursor(original: Cursor!)
                    print("转换",saveCursor)
                    UserDefaults.standard.set(saveCursor, forKey: "cursor")
                }else {
                    self.isLoadAll = true
                }
                DispatchQueue.main.async {
                    print("数据量", self.Records.count)
                    self.tableView.reloadData()
                }
            }else {
                print("加载出错", e.debugDescription)
            }
        }
        
    }
    
    @objc func refreshData() {
       //获取上次加载数据的节点
        var operation : CKQueryOperation!
        
    
        let query = CKQuery(recordType: "BlogData", predicate: NSPredicate(value: true))
        ///添加排序条件，此方法会作用于后面用于更新的CKCursor
        query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        operation = CKQueryOperation(query: query)
        
        operation?.resultsLimit = 1
        
        ///返回的每一条查询数据
        operation?.recordFetchedBlock = {record in
            ///判断是否已经加载了
            if self.RecordIDs.contains(record.recordID) {
                print("已经有了")
                DispatchQueue.main.async {
                    self.refresh.endRefreshing()
                }
            }else{
                self.Records.insert(record, at: 0)
                self.RecordIDs.append(record.recordID)
              
                //保存到本地coreData
                CoreDataManager.saveCDRecords(record: record)
            }
            
        }
        
        let publicDatabase = CKContainer.default().publicCloudDatabase
        
        ///此时才开始获取数据
        publicDatabase.add(operation!)
        
        ///执行完所有获取操作
        operation?.queryCompletionBlock = { (Cursor, e) in
            if e == nil {
                ///保存浏览记录
                print("节点", Cursor)
                if Cursor != nil {
                    let saveCursor = archiverCursor(original: Cursor!)
                    print("转换",saveCursor)
                    UserDefaults.standard.set(saveCursor, forKey: "cursor")
                }
                
                DispatchQueue.main.async {
                    print("刷新数据量", self.Records.count)
                    ///重新按照时间排序
                    self.Records.sort { (record1, record2) -> Bool in
                        record1.creationDate!.compare(record2.creationDate!) == .orderedDescending
                    }
                    self.tableView.reloadData()
                    self.refresh.endRefreshing()
                }
            }else {
                print("加载出错", e.debugDescription)
            }
        }
    }
    
    func readCoreData() {
        let request = NSFetchRequest<CDRecords>(entityName: "CDRecords")
        request.fetchLimit = 10
        let sortDes = NSSortDescriptor(key: "writeDate", ascending: false)
        request.sortDescriptors = [sortDes]
        let results : Array = try! CoreDataManager.managedContext.fetch(request)
        print("现有本地数据量", results.count)
        for result in results {
            let unarchiver = try? NSKeyedUnarchiver.init(forReadingFrom: result.cd_record!)
            let record = CKRecord(coder: unarchiver!)
            self.Records.append(record!)
            self.RecordIDs.append(record!.recordID)
        }
        
    }
    
    
}



extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.Records.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MainCell" ,for: indexPath)  as! MainTableViewCell
        cell.setUI()
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
        DispatchQueue.main.async {
            if indexPath.row == self.Records.count - 1{
                if !self.isLoadAll {
                    self.QuaryData()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        for view in cell.subviews {
            view.removeFromSuperview()
        }
    }
    
    
    
}
