//
//  ActivityIndicator.swift
//  CloudKit_Demo
//
//  Created by Mac on 2020/4/20.
//  Copyright © 2020 Mac. All rights reserved.
//

import Foundation
import UIKit

class  ActivityIndicator {
    
    lazy var loading = UIActivityIndicatorView()
    
    lazy var loadingBGV = UIView()
    
    static var shared:ActivityIndicator = {
        let instance = ActivityIndicator()
        return instance
    }()
    
   
    func start(viewController:UIViewController, complition:@escaping ()->()) {
        
        self.loadingBGV = UIView.init(frame: viewController.view.frame)
        self.loadingBGV.backgroundColor = UIColor.init(white: 0.3, alpha: 0.3)
        self.loadingBGV.alpha = 0
        viewController.view.addSubview(self.loadingBGV)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.loadingBGV.alpha = 1
        }) { (_) in
            self.loading.frame = CGRect(origin: viewController.view.center, size: CGSize(width: 60, height: 60))
            self.loading.center = viewController.view.center
            self.loading.backgroundColor = .white
            self.loading.layer.cornerRadius = 10
            
            viewController.view.addSubview(self.loading)
            
            self.loading.startAnimating()
            
            //最后执行
            complition()
        }
    }
    
    func dismiss(viewController:UIViewController, compolition:@escaping ()->()) {
        DispatchQueue.main.async {
            self.loading.stopAnimating()
            self.loading.removeFromSuperview()
            UIView.animate(withDuration: 0.3, animations: {
                self.loadingBGV.alpha = 0
            }) { (_) in
                self.loadingBGV.removeFromSuperview()
                compolition()
            }
        }
        
    }
 
}
