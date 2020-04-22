//
//  mineViewController.swift
//  CloudKit_Demo
//
//  Created by Mac on 2020/4/8.
//  Copyright © 2020 Mac. All rights reserved.
//

import UIKit

class mineViewController: UIViewController {
    
    let RNaviItem = UIBarButtonItem()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.setUI()

    }
   
    
    private func setUI() {
        
        self.RNaviItem.image = UIImage(named: "caidan")?.withRenderingMode(.alwaysOriginal)
        self.RNaviItem.target = self
        self.RNaviItem.action = #selector(toSetting)
        self.navigationItem.rightBarButtonItems = [self.RNaviItem]
        
        ///如果带问号可选的话，就不能修改子页面的返回按钮
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        self.navigationItem.backBarButtonItem?.tintColor = UIColor.dynamicColor(lightColor: .black, darkColor: .white)
        
    }
    
    @objc func toSetting() {
        let VC = SettingViewController()
        VC.hidesBottomBarWhenPushed = true
        
        ///强制初始化页面，以便盖住tabBar
        VC.view.backgroundColor = UIColor.dynamicColor(lightColor: .white, darkColor: .black)
        self.navigationController?.pushViewController(VC, animated: true)
        
    }

}
