//
//  SettingViewController.swift
//  CloudKit_Demo
//
//  Created by Mac on 2020/4/21.
//  Copyright © 2020 Mac. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.title = "设置"
        DispatchQueue.main.async {
            self.setUI()
        }
        
    }
    
    
    private func setUI() {
        let quitIMG = UIImageView(image: UIImage(named: "tuichu"))
        quitIMG.frame = CGRect(origin: .zero, size: CGSize(width: 30, height: 30))
        quitIMG.center = CGPoint(x: 35, y: self.navigationController!.navigationBar.frame.height + UIApplication.shared.statusBarFrame.height + 50)
        
        view.addSubview(quitIMG)
        
        let quitBtn = UIButton(frame: CGRect(origin: CGPoint(x: 60, y: self.navigationController!.navigationBar.frame.height + UIApplication.shared.statusBarFrame.height + 35), size: CGSize(width: 50, height: 30)))
        quitBtn.setTitle("退出", for: [])
        quitBtn.setTitleColor(UIColor.dynamicColor(lightColor: .black, darkColor: .white), for: [])
        quitBtn.addTarget(self, action: #selector(quitAccount), for: .touchUpInside)
        view.addSubview(quitBtn)
        
        let lineView = UIView(frame: CGRect(origin: CGPoint(x: 60, y: self.navigationController!.navigationBar.frame.height + UIApplication.shared.statusBarFrame.height + 70), size: CGSize(width: self.view.frame.width - 80, height: 1)))
        lineView.backgroundColor = UIColor.dynamicColor(lightColor: .systemGray3, darkColor: .white)
        view.addSubview(lineView)
    }
    
    @objc func quitAccount() {
        let userDefault = UserDefaults.standard
        userDefault.set(nil, forKey: "userName")
        let vc = LoginViewController()
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true) {
            self.navigationController?.popViewController(animated: true)
        }
    }

}
