//
//  ViewController.swift
//  CloudKit_Demo
//
//  Created by Mac on 2020/4/8.
//  Copyright © 2020 Mac. All rights reserved.
//

import UIKit
import CloudKit

class ViewController: UIViewController {

    var btn : UIButton?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        self.btn = UIButton(frame: CGRect(origin: view.center, size: CGSize(width: 200, height: 50)))
        self.btn?.center = view.center
        self.btn?.setTitle("CloudKit测试", for: [])
        self.btn?.setTitleColor(UIColor.init(dynamicProvider: { (TC) -> UIColor in
            switch TC.userInterfaceStyle{
            case .dark:
                return .white
            case .light:
                return .black
            case .unspecified:
                return .white
            @unknown default:
                return .white
            }
        }), for: [])
        self.btn?.addTarget(self, action: #selector(testBtn), for: .touchUpInside)
        view.addSubview(self.btn!)
    }
    
    @objc
    func testBtn(){
        print("test")
    }


}

