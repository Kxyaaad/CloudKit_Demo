//
//  RegisterViewController.swift
//  CloudKit_Demo
//
//  Created by Mac on 2020/4/20.
//  Copyright © 2020 Mac. All rights reserved.
//

import UIKit
import CloudKit

class RegisterViewController: BaseViewController {
    
    let userName = UITextField()
    
    let passWord = UITextField()
    
    let comfirmPW = UITextField()
    
    let register = UIButton()
    
    let login = UIButton()
    
    let loading = UIActivityIndicatorView.init(style: .medium)
    
    let loadingBGV = UIView()
    
    var isisRegisteSuccessed : isRegisteSuccessedDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUI()
    }
    
    private func setUI() {
        view.backgroundColor = .systemBlue
        view.addSubview(self.userName)
        view.addSubview(self.passWord)
        view.addSubview(self.comfirmPW)
        view.addSubview(self.register)
        
        self.userName.frame.size = CGSize(width: ScreenWidth / 2, height: 40)
        self.userName.backgroundColor = .white
        self.userName.center = CGPoint(x: ScreenWidth/2, y: ScreenHeight/2-100)
        self.userName.layer.cornerRadius = 10
        self.userName.textColor = .black
        self.userName.placeholder = "请输入用户名"
        
        self.passWord.frame.size = CGSize(width: ScreenWidth / 2, height: 40)
        self.passWord.backgroundColor = .white
        self.passWord.center = CGPoint(x: ScreenWidth/2, y: ScreenHeight/2 - 40)
        self.passWord.layer.cornerRadius = 10
        self.passWord.placeholder = "请输入密码"
        self.passWord.textColor = .black
        self.passWord.isSecureTextEntry = true
        
        self.comfirmPW.frame.size = CGSize(width: ScreenWidth / 2, height: 40)
        self.comfirmPW.backgroundColor = .white
        self.comfirmPW.center = CGPoint(x: ScreenWidth/2, y: ScreenHeight/2 + 20)
        self.comfirmPW.layer.cornerRadius = 10
        self.comfirmPW.textColor = .black
        self.comfirmPW.placeholder = "请确认密码"
        self.comfirmPW.isSecureTextEntry = true
        
        self.register.frame.size = CGSize(width: 100, height: 50)
        self.register.center = CGPoint(x: ScreenWidth/2, y: ScreenHeight/2+100)
        self.register.setTitle("注册", for: [])
        self.register.setTitleColor(.white, for: .normal)
        self.register.addTarget(self, action: #selector(RegisterAccount), for: .touchUpInside)
        
    }
    
    @objc func RegisterAccount() {
        
        if self.userName.text == "" {
            let alert = UIAlertController(title: "请输入您想注册的用户名", message: nil, preferredStyle: .alert)
            
            let ac1 = UIAlertAction(title: "确认", style: .default) { (_) in
                
            }
            alert.addAction(ac1)
            self.present(alert, animated: true, completion: nil)
            return
        }else if self.userName.text!.allSatisfy({ (char) -> Bool in
            return char.isWhitespace
        }) {
            let alert = UIAlertController(title: "用户名不得为空", message: nil, preferredStyle: .alert)
            
            let ac1 = UIAlertAction(title: "确认", style: .default) { (_) in
                
            }
            alert.addAction(ac1)
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        if self.passWord.text != self.comfirmPW.text {
            let alert = UIAlertController(title: "两次输入密码不一致", message: nil, preferredStyle: .alert)
            
            let ac1 = UIAlertAction(title: "确认", style: .default) { (_) in
                
            }
            alert.addAction(ac1)
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        ///开始提交注册
        
        ActivityIndicator.shared.start(viewController: self) {
            self.registerID()
        }
        
    }
    
    //提交注册
    private func registerID() {
        let registerRecordID = CKRecord.ID(recordName: self.userName.text!)
        let registerRecord = CKRecord(recordType: "UserAccouts", recordID: registerRecordID)
        
        registerRecord["PassWord"] = self.passWord.text!
        
        let myContainer = CKContainer.default()
        let pbData = myContainer.publicCloudDatabase
        
        pbData.save(registerRecord) { (record, erroe) in
            if let error = erroe {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "错误", message: error.localizedDescription, preferredStyle: .alert)
                    
                    let ac1 = UIAlertAction(title: "确认", style: .default) { (_) in
                        
                    }
                    alert.addAction(ac1)
                    self.present(alert, animated: true, completion: {
                        ActivityIndicator.shared.dismiss(viewController: self) {
                            
                        }
                    })
                }
                
                
                return
            }
            print("注册结果",record as Any)
            
            DispatchQueue.main.async {
                let userDefault = UserDefaults.standard
                userDefault.set(self.userName.text!, forKey: "userName")
                
                ///发送登录成功通知
                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: UserLoginSuccessedNotification)))
            }
            
           
            ActivityIndicator.shared.dismiss(viewController: self) {
                self.dismiss(animated: true) {
                    self.isisRegisteSuccessed?.isisRegisteSuccessed(isisRegisteSuccessed: true)
                }
            }
        }
    }
}

protocol isRegisteSuccessedDelegate  {
    func isisRegisteSuccessed(isisRegisteSuccessed:Bool)
}
