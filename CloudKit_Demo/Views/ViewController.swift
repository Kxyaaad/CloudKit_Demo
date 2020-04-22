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
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setUI()
        print("加载第一个页面")
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
        view.addSubview(self.tableView)
        
        self.QuaryData()
    }
    
    @objc
    func QuaryData(){
        let publicDatabase = CKContainer.default().publicCloudDatabase
        
        publicDatabase.perform(CKQuery.init(recordType: "TestType", predicate: NSPredicate.init(value: true)), inZoneWith: nil) { (records, error) in
//            print("获取记录",records)
            if records != nil {
                self.Records = records!
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            }
        }
        
        
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.Records.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MainCell", for: indexPath)  as! MainTableViewCell
        cell.record = self.Records[indexPath.row]
        print("获取到的数据", cell.record as Any)
        cell.setUI()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.view.frame.width + 60
    }
    
}

