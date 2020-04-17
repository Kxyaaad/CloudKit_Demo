//
//  pickImageCell.swift
//  CloudKit_Demo
//
//  Created by Mac on 2020/4/9.
//  Copyright © 2020 Mac. All rights reserved.
//

import UIKit

class pickImageCell: UICollectionViewCell {
    
    var imgView : UIImageView?
    var longPress : UILongPressGestureRecognizer!
    var delateBtn : UIButton?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.imgView = UIImageView()
        self.imgView?.frame = CGRect(origin: .zero, size: CGSize(width: self.frame.width, height: self.frame.height))
        self.imgView?.layer.cornerRadius = 6
        self.addSubview(self.imgView!)
        self.longPress = UILongPressGestureRecognizer()
        self.addGestureRecognizer(self.longPress)
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
