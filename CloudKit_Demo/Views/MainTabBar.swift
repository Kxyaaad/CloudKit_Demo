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
//        self.addChild(ViewController())
        
        self.addChildViewController(child: ViewController(), title: "主页", imageName: "tabbarhomeselect", selectedImageName: "tabbarhomeselect", index: 0, isEnable: true)
        self.addChildViewController(child: blankViewController(), title: "", imageName: "", selectedImageName: "", index: 1, isEnable: false)
        self.addChildViewController(child: mineViewController(), title: "我的", imageName: "tabbarhomeselect", selectedImageName: "tabbarhomeselect", index: 2, isEnable: true)
        self.addBtn()
        delegate = self
    
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
        btn.center = CGPoint(x: self.view.frame.width/2, y: self.tabBar.frame.origin.y-5)
//        btn.backgroundColor = .red
        btn.setBackgroundImage(UIImage.init(named: "tianjia"), for: [])
        self.view.addSubview(btn)
        btn.addTarget(self, action: #selector(toAddNew), for: .touchUpInside)
        
    }
    
    @objc
    func toAddNew() {
        let vc = addNewController()
        vc.view.frame = self.view.frame
        present(vc, animated: true, completion: nil)
    
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController == tabBarController.viewControllers![1] {
            return false
        }else {
            return true
        }
    }
  
    
}
