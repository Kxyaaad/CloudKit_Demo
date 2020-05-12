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
        self.userName.textColor = .black
        self.userName.placeholder = "请输入用户名"
        
        self.passWord.frame.size = CGSize(width: ScreenWidth / 2, height: 40)
        self.passWord.backgroundColor = .white
        self.passWord.center = CGPoint(x: ScreenWidth/2, y: ScreenHeight/2 - 40)
        self.passWord.layer.cornerRadius = 10
        self.passWord.textColor = .black
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
        self.register.addTarget(self, action: #selector(Register), for: .touchUpInside)
        
    }
    
    
    @objc func Login() {
        if self.userName.text != "" && self.passWord.text != "" {
            let pbData = CKContainer.default().publicCloudDatabase
            let predicate = NSPredicate(format: "PassWord = %@", self.userName.text!)
            print(predicate)
            pbData.perform(CKQuery.init(recordType: "UserAccouts", predicate: predicate), inZoneWith: nil) { (records, error) in
                if error == nil {
                    print("查询结果", records as Any)
                    if records == [] {
                        ///主线程中进行界面更新，否则会崩溃
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: "未找到相关用户", message: "请确认您输入的用户名是否正确，或请您注册。", preferredStyle: .alert)
                            
                            let ac1 = UIAlertAction(title: "注册", style: .default) { (_) in
                                //跳转到注册页面
                                self.Register()
                            }
                            
                            let ac2 = UIAlertAction(title: "取消", style: .cancel) { (_) in
                                
                            }
                            alert.addAction(ac1)
                            alert.addAction(ac2)
                            self.present(alert, animated: true, completion: nil)
                        }
                        
                    }else{
                        if records![0]["PassWord"] == self.passWord.text  {
                            print("登录成功")
                            DispatchQueue.main.async {
                                let userDefault = UserDefaults.standard
                                userDefault.set(self.userName.text!, forKey: "userName")
                                
                                ///发送登录成功通知
                                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: UserLoginSuccessedNotification)))
                                self.dismiss(animated: false, completion: nil)
                            }
                        }
                    }
                    
                }else {
                    print("查询错误",error?.localizedDescription as Any)
                }
            }
            
            
        }else {
            let alert = UIAlertController(title: nil, message: "用户名和密码不能为空！", preferredStyle: .alert)
            let ac = UIAlertAction(title: "确定", style: .cancel) { (_) in
                
            }
            
            alert.addAction(ac)
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    @objc func Register() {
        let vc = RegisterViewController()
        vc.isisRegisteSuccessed = self
        self.present(vc, animated: true, completion: nil)
    }
    
}

extension LoginViewController:isRegisteSuccessedDelegate{
    func isisRegisteSuccessed(isisRegisteSuccessed: Bool) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}

