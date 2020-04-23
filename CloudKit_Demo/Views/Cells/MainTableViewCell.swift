//
//  MainTableViewCell.swift
//  CloudKit_Demo
//
//  Created by Mac on 2020/4/15.
//  Copyright © 2020 Mac. All rights reserved.
//

import UIKit
import CloudKit
import Kingfisher
import SnapKit

class MainTableViewCell: UITableViewCell {
    
    lazy var imageScroller = UIScrollView()
    
    
    var record : CKRecord?
    
    var desLabelHeight : CGFloat?
    
    ///避免cell重复加载控件造成卡顿和内存溢出
    var isLoad = false
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
     
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
}

extension MainTableViewCell: UIScrollViewDelegate {
    
    public func setUI() {
        print("重载cell")
        let nameLab = UILabel(frame: CGRect(origin: CGPoint(x: 30, y: 10), size: CGSize(width: self.frame.width, height: 20)))
        nameLab.text = self.record!["Artist"] as? String
        
        self.addSubview(nameLab)
        
        let desLabel = UILabel(frame: CGRect(origin: CGPoint(x: 10, y: 30), size: CGSize(width: self.frame.width - 20, height: self.desLabelHeight ?? 30)))
        desLabel.text = self.record!["des"] as? String
        desLabel.numberOfLines = 0
        desLabel.font = UIFont.systemFont(ofSize: 15)
        self.addSubview(desLabel)
        
        self.imageScroller.frame = CGRect(origin: CGPoint(x: 0, y: 30 + (self.desLabelHeight ?? 35)), size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width))
        self.imageScroller.contentSize = CGSize(width: UIScreen.main.bounds.width * CGFloat((self.record!["images"] as! Array<CKAsset>).count), height: UIScreen.main.bounds.width)
        self.imageScroller.isPagingEnabled = true
        self.imageScroller.showsHorizontalScrollIndicator = false
        self.addSubview(self.imageScroller)
        
        imageScroller.snp.makeConstraints { (make) in
            make.bottomMargin.equalToSuperview().offset(-30)
            make.size.equalTo(UIScreen.main.bounds.width)
        }
        
        let timeLab = UILabel(frame: CGRect(origin: CGPoint(x: 20, y: 35 + (self.desLabelHeight ?? 40) + UIScreen.main.bounds.width), size: CGSize(width: self.frame.width, height: 20)))
        timeLab.text = self.record?.creationDate?.description
        timeLab.textColor = UIColor.dynamicColor(lightColor: UIColor.init(white: 0.4, alpha: 1), darkColor: .white)
        timeLab.font = UIFont.systemFont(ofSize: 13)
        self.addSubview(timeLab)
        
        ///加载图片
        if self.record != nil {
            let images = self.record!["images"] as! Array<CKAsset>
            
            for i in 0..<images.count {
                
                let imageView = UIImageView(frame:  CGRect(origin: CGPoint(x: CGFloat(i) * UIScreen.main.bounds.width, y: 0), size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)))
                
                self.imageScroller.addSubview(imageView)
                
                DispatchQueue.main.async {
                    imageView.image = UIImage.init(data: try! Data.init(contentsOf: images[i].fileURL!))
                }

            }
        }else {
            print("数据为空")
        }
        
        self.isLoad = true
    }

}
