//
//  MainTabBar.swift
//  CloudKit_Demo
//
//  Created by Mac on 2020/4/8.
//  Copyright © 2020 Mac. All rights reserved.
//

import UIKit
import SnapKit

class MainTabBar: UITabBarController,UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.addChildViewController(child: ViewController(), title: "主页", imageName: "tabbarhomeselect", selectedImageName: "tabbarhomeselect", index: 0, isEnable: true)
        self.addChild(blankViewController())
        
        self.addChildViewController(child: mineViewController(), title: "我的", imageName: "tabbarhomeselect", selectedImageName: "tabbarhomeselect", index: 2, isEnable: true)
        
        ///主线程中添加才会添加到界面的最上方
        DispatchQueue.main.async {
            self.addBtn()
        }
    
        delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(loginSuccess(Noti:)), name: NSNotification.Name(rawValue: UserLoginSuccessedNotification), object: nil)
        
    }
    
    deinit {
        ///注销通知
        NotificationCenter.default.removeObserver(self)
    }
    
    private func addChildViewController(child:UIViewController, title:String, imageName:String, selectedImageName:String, index:Int, isEnable:Bool) {
        let navigition = UINavigationController(rootViewController: child)
        child.title = title
        child.tabBarItem.tag = index
        child.tabBarItem.isEnabled = isEnable
        child.tabBarItem.image = UIImage.init(named: imageName)?.withRenderingMode(.automatic)
        child.tabBarItem.selectedImage = UIImage.init(named: selectedImageName)?.withRenderingMode(.automatic)
        self.addChild(navigition)
    }
    
    private func addBtn() {
        let btn = UIButton(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 50, height: 50)))
        btn.center = CGPoint(x: self.view.frame.width/2, y: 25)
        //        btn.backgroundColor = .red
        btn.setBackgroundImage(UIImage.init(named: "tianjia"), for: [])
        tabBar.addSubview(btn)
        btn.addTarget(self, action: #selector(toAddNew), for: .touchUpInside)
        
    }
    
    @objc
    func toAddNew() {
        let vc = addNewController()
        vc.view.frame = self.view.frame
        present(vc, animated: true, completion: nil)
        
    }
    
    
}


extension MainTabBar {
    ///登录成功
    @objc private func loginSuccess(Noti: Notification) {
        
    }
    
}
