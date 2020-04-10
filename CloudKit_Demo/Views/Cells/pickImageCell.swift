//
//  pickImageCell.swift
//  CloudKit_Demo
//
//  Created by Mac on 2020/4/9.
//  Copyright © 2020 Mac. All rights reserved.
//

import UIKit

class pickImageCell: UICollectionViewCell {
    
    var touchBtn : UIButton?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        self.touchBtn = UIButton()
        self.touchBtn?.frame = frame
        self.touchBtn?.layer.cornerRadius = 6
        self.addSubview(self.touchBtn!)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
