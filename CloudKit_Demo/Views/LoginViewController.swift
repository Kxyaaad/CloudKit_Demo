//
//  LoginViewController.swift
//  CloudKit_Demo
//
//  Created by Mac on 2020/4/16.
//  Copyright © 2020 Mac. All rights reserved.
//

import UIKit
import CloudKit

class LoginViewController: UIViewController {

    let userName = UITextField()
    
    let passWord = UITextField()
    
    let register = UIButton()
    
    let login = UIButton()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setUI()
        
        
    }
    
    private func setUI() {
        view.backgroundColor = .systemBlue
        view.addSubview(self.userName)
        view.addSubview(self.passWord)
        view.addSubview(self.login)
        view.addSubview(self.register)
        
        self.userName.frame.size = CGSize(width: ScreenWidth / 2, height: 40)
        self.userName.backgroundColor = .white
        self.userName.center = CGPoint(x: ScreenWidth/2, y: ScreenHeight/2-100)
        self.userName.layer.cornerRadius = 10
        self.userName.placeholder = "请输入用户名"
        
        self.passWord.frame.size = CGSize(width: ScreenWidth / 2, height: 40)
        self.passWord.backgroundColor = .white
        self.passWord.center = CGPoint(x: ScreenWidth/2, y: ScreenHeight/2 - 40)
        self.passWord.layer.cornerRadius = 10
        self.passWord.placeholder = "请输入密码"
        self.passWord.isSecureTextEntry = true
        
        self.login.frame.size = CGSize(width: 100, height: 50)
        self.login.center = CGPoint(x: ScreenWidth/2, y: ScreenHeight/2+40)
        self.login.setTitle("登录", for: [])
        self.login.setTitleColor(.white, for: .normal)
        self.login.addTarget(self, action: #selector(Login), for: .touchUpInside)
        
        self.register.frame.size = CGSize(width: 100, height: 50)
        self.register.center = CGPoint(x: ScreenWidth/2, y: ScreenHeight/2+100)
        self.register.setTitle("注册", for: [])
        self.register.setTitleColor(.white, for: .normal)
        
    }
    
    
    @objc func Login() {
        if self.userName.text != "" && self.passWord.text != "" {
            let pbData = CKContainer.default().publicCloudDatabase
//            let logRecord = CKRecord.init(recordType: "Users", recordID: CKRecord.ID(recordName: self.userName.text!))
            let predicate = NSPredicate(format: "description = %@", self.userName.text!)
            print(predicate)
            pbData.perform(CKQuery.init(recordType: "Users", predicate: predicate), inZoneWith: nil) { (records, error) in
                if error == nil {
                    print("查询结果", records)
                }else {
                    print("查询错误", error.de)
                }
            }
//            pbData.fetch(withRecordID: logRecordID) { (record, error) in
//                if error == nil {
//                    print("查询结果", record)
//                }else {
//                    DispatchQueue.main.async {
//                        let alert = UIAlertController(title: nil, message: "用户名不存在", preferredStyle: .alert)
//                        let ac = UIAlertAction(title: "确定", style: .cancel) { (_) in
//                            
//                        }
//                        
//                        alert.addAction(ac)
//                        self.present(alert, animated: true, completion: nil)
//                    }
//                    
//                }
//            }
            
            
        }else {
            let alert = UIAlertController(title: nil, message: "用户名和密码不能为空！", preferredStyle: .alert)
            let ac = UIAlertAction(title: "确定", style: .cancel) { (_) in
                
            }
            
            alert.addAction(ac)
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    @objc func Register() {
       
    }
    
}

