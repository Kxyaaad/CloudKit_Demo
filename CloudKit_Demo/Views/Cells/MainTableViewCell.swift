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

class MainTableViewCell: UITableViewCell {

    lazy var imageScroller = UIScrollView()
    
    var record : CKRecord?
    
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
        
        let desLabel = UILabel(frame: CGRect(origin: .zero, size: CGSize(width: self.frame.width, height: 50)))
        desLabel.text = self.record!["description"] as! String
        self.addSubview(desLabel)
        
        self.imageScroller.frame = CGRect(origin: CGPoint(x: 0, y: 50), size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width))
        self.imageScroller.contentSize = CGSize(width: UIScreen.main.bounds.width * CGFloat((self.record!["images"] as! Array<CKAsset>).count), height: UIScreen.main.bounds.width)
        self.imageScroller.isPagingEnabled = true
        self.imageScroller.showsHorizontalScrollIndicator = false
        self.addSubview(self.imageScroller)
        
        if self.record != nil {
            print("有数据")
            let images = self.record!["images"] as! Array<CKAsset>
            
            for i in 0..<images.count {
                let imageView = UIImageView(frame:  CGRect(origin: CGPoint(x: CGFloat(i) * UIScreen.main.bounds.width, y: 0), size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)))
                imageView.backgroundColor = .red
                self.imageScroller.addSubview(imageView)
                do {
                    let imageData = try Data.init(contentsOf: images[i].fileURL!)
                    DispatchQueue.main.async {
                        imageView.image = UIImage.init(data: imageData)
                    }
                }catch{(error)
                    print("图片加载错误", error)
                }
                
                
            }
        }else {
            print("数据为空")
        }
    }
}
