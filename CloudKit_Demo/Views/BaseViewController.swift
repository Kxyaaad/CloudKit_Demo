//
//  BaseViewController.swift
//  CloudKit_Demo
//
//  Created by Mac on 2020/4/21.
//  Copyright © 2020 Mac. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(loginSuccess(Noti:)), name: NSNotification.Name(rawValue: UserLoginSuccessedNotification), object: nil)
    }
    
    deinit {
           ///注销通知
           NotificationCenter.default.removeObserver(self)
       }
    
    @objc private func loginSuccess(Noti: Notification) {
           print("收到登录成功通知")
        ///强制刷新界面
           view = nil
       }
}
