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
    
    var record : CKRecord!
    
    var desLabelHeight : CGFloat?
    
    var nameLab : UILabel?
    
    var desLabel : UILabel?
    
    var timeLab : UILabel?
    
    lazy var image1 = UIImageView()
    lazy var image2 = UIImageView()
    lazy var image3 = UIImageView()
    lazy var image4 = UIImageView()
    lazy var image5 = UIImageView()
    lazy var image6 = UIImageView()
    lazy var image7 = UIImageView()
    lazy var image8 = UIImageView()
    lazy var image9 = UIImageView()
    
    ///避免cell重复加载控件造成卡顿和内存溢出
    var isLoad = false
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
     
        self.setUI()
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
        self.selectionStyle = .none
        // Configure the view for the selected state
    }
    
    
}

extension MainTableViewCell: UIScrollViewDelegate {
    
    public func setUI() {
        nameLab = UILabel(frame: CGRect(origin: CGPoint(x: 30, y: 10), size: CGSize(width: self.frame.width, height: 20)))
//        nameLab.text = self.record!["Artist"] as? String
        
        self.addSubview(nameLab!)
        
        desLabel = UILabel(frame: CGRect(origin: CGPoint(x: 10, y: 30), size: CGSize(width: self.frame.width - 20, height: self.desLabelHeight ?? 30)))
//        desLabel.text = self.record!["des"] as? String
        desLabel!.numberOfLines = 0
        desLabel!.font = UIFont.systemFont(ofSize: 15)
        self.addSubview(desLabel!)
        
        self.imageScroller = UIScrollView()
        self.imageScroller.isPagingEnabled = true
        self.imageScroller.backgroundColor = .red
        self.imageScroller.showsHorizontalScrollIndicator = false
        self.addSubview(self.imageScroller)
            
        
        timeLab = UILabel(frame: CGRect(origin: CGPoint(x: 20, y: 35 + (self.desLabelHeight ?? 30 ) + UIScreen.main.bounds.width), size: CGSize(width: self.frame.width, height: 20)))
//        timeLab?.text = self.record?.creationDate?.description
        timeLab?.textColor = UIColor.dynamicColor(lightColor: UIColor.init(white: 0.4, alpha: 1), darkColor: .white)
        timeLab?.font = UIFont.systemFont(ofSize: 13)
        self.addSubview(timeLab!)
        

    }
    
    ///获取数据后再加载图片
    public func loadImage() {
        
        let images = self.record!["images"] as! Array<CKAsset>
        
        if images.count > 0 {
            for i in 0..<images.count{
                let imageView = UIImageView(frame:  CGRect(origin: CGPoint(x: CGFloat(i) * UIScreen.main.bounds.width, y: 0), size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)))
                imageView.tag = i
                imageView.backgroundColor = UIColor(white: CGFloat(Double(i)/10.0), alpha: 1)
                self.imageScroller.addSubview(imageView)
               
                do {
//                    let imageData =
//                    let image = UIImage.init(data: imageData!)
//                    data = UIImageJPEGRepresentation(self, 0.2)!
                    let image = UIImage.init(data: try! Data.init(contentsOf: images[i].fileURL!), scale: 0.01)
                    imageView.image = image!
                }catch {
                    print("图片读取错误")
                }
                imageView.kf.setImage(with:  images[i].fileURL!)
            }
        }
        
    }

}
