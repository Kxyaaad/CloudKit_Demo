//
//  addNewController.swift
//  CloudKit_Demo
//
//  Created by Mac on 2020/4/8.
//  Copyright © 2020 Mac. All rights reserved.
//

import UIKit
import SnapKit
import CloudKit
import Photos

class addNewController: BaseViewController {
    
    var textInput : UITextView?
    
    var imgCollection : UICollectionView?
    
    var imgsData : Array<UIImage> = []
    
    var imgsURL : Array<URL> = []
    ///发布按钮
    var postBtn = UIButton()
    
    //用于删除image的view
    lazy var delateView = UIView()
    
    lazy var delateLabel = UILabel()
    //拖拽图片的index
    lazy var indexPath = IndexPath()
    
    lazy var DragedImg = UIImageView()
    
    lazy var cellPoint = CGPoint()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        // Do any additional setup after loading the view.
    }
    
    private func setUpUI() {
        view.backgroundColor = UIColor.dynamicColor(lightColor: UIColor.init(white: 0.8, alpha: 1), darkColor: UIColor.init(white: 0.2, alpha: 1))
        
        self.postBtn.setTitle("发布", for: [])
        self.postBtn.setTitleColor(UIColor.dynamicColor(lightColor: .systemBlue, darkColor: .systemGreen), for: [])
        self.postBtn.addTarget(self, action: #selector(upLoad), for: .touchUpInside)
        view.addSubview(self.postBtn)
        self.postBtn.snp.makeConstraints { (make) in
            make.rightMargin.equalTo(20)
            make.topMargin.equalTo(20)
            make.width.equalTo(100)
            make.height.equalTo(50)
        }
        
        //输入框
        self.textInput = UITextView()
        self.textInput?.font = .systemFont(ofSize: 15)
        self.textInput?.layer.cornerRadius = 10
        self.textInput?.delegate = self
        self.textInput?.backgroundColor = UIColor.dynamicColor(lightColor: UIColor.init(white: 1, alpha: 1), darkColor: UIColor.init(white: 0, alpha: 1))
        view.addSubview(self.textInput!)
        self.textInput?.becomeFirstResponder()
        
        self.textInput?.frame = CGRect(origin: CGPoint(x: 20, y: 70), size: CGSize(width: self.view.frame.width-40, height: 200))
        
        
        
        //选择图片
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 80, height: 80)
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets.init(top: 10, left: 10, bottom: 10, right: 10)
        
        self.imgCollection = UICollectionView(frame: CGRect(origin: CGPoint(x: 20, y: 290), size: CGSize(width: self.view.frame.width - 40, height: 400)), collectionViewLayout: layout)
        self.imgCollection?.delegate = self
        self.imgCollection?.dataSource = self
        self.imgCollection?.register(pickImageCell.self, forCellWithReuseIdentifier: "PICKIMAGE")
        self.imgCollection?.backgroundColor = UIColor.dynamicColor(lightColor: UIColor.init(white: 0.8, alpha: 1), darkColor: UIColor.init(white: 0.2, alpha: 1))
        
        
        self.imgCollection?.setCollectionViewLayout(layout, animated: true)
        
        view.addSubview(self.imgCollection!)
        
    }
    
    
    @objc
    private func upLoad() {
        ActivityIndicator.shared.start(viewController: self) {
            
        }
        //新建
        let artworkRecordID = CKRecord.ID()
        let artworkRecord = CKRecord(recordType: "BlogData", recordID: artworkRecordID)
        artworkRecord["des"] = self.textInput!.text
        artworkRecord["Artist"] = UserDefaults.standard.string(forKey: "userName")!
        //添加图片
        var imgAssets : Array<CKAsset> = []
        for i in 0..<self.imgsURL.count {
            let photoAsset = CKAsset(fileURL: self.imgsURL[i])
            imgAssets.append(photoAsset)
        }
        
        artworkRecord["images"] = imgAssets

        
        //to save
        //公共数据库
        let myContainer = CKContainer.default()
        let publicDB = myContainer.publicCloudDatabase
        
        publicDB.save(artworkRecord) { (record, error) in
            if let error = error {
                print("错误",error)
                return
            }
            print("保存完毕")
            ActivityIndicator.shared.dismiss(viewController: self) {
                self.dismiss(animated: true) {
                    NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: UpdataBlogNotification)))
                }
            }
        }
        
    }
    
    
}


extension addNewController:UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        print("完成")
    }
    
    
}

extension addNewController:UICollectionViewDelegate,UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imgsData.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PICKIMAGE", for: indexPath) as! pickImageCell
        if indexPath.row  == self.imgsData.count {
            cell.imgView?.image = UIImage.init(named: "tianjiatupian")
        }else if indexPath == self.indexPath {
            cell.imgView?.image = nil
        } else {
            cell.imgView?.image = self.imgsData[indexPath.row]
            cell.longPress.addTarget(self, action: #selector(longPress(longPress:)))
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == self.imgsData.count{
            self.getAlbumList()
        }
    }
    
    //长按功能
    @objc
    func longPress(longPress: UILongPressGestureRecognizer) {
        switch longPress.state {
        case .began:
            self.delateViewShowOn()
            self.dragBegan(point: longPress.location(in: self.imgCollection!), cellPoint: longPress.location(in: longPress.view))
        case .changed:
            self.dragChanged(point: longPress.location(in: self.view))
        case .ended:
            self.dragEnd(point: longPress.location(in: self.view))
        default:
            print("default")
        }
        
        
        
    }
    
    private func dragBegan(point:CGPoint, cellPoint:CGPoint) {
        
        self.indexPath = self.imgCollection!.indexPathForItem(at: point)!
        self.cellPoint = cellPoint
        print(self.indexPath, cellPoint)
        
    }
    
    private func dragChanged(point: CGPoint) {
        self.imgCollection?.reloadData()
        self.view.insertSubview(self.DragedImg, belowSubview: self.delateView)
        self.DragedImg.frame = CGRect(origin: CGPoint(x: point.x - self.cellPoint.x, y: point.y  - cellPoint.y), size: CGSize(width: 80, height: 80))
        
        self.DragedImg.image = self.imgsData[indexPath.row]
        
        if point.y > self.view.frame.height - 100 - self.additionalSafeAreaInsets.bottom {
            self.delateLabel.text = "松开以删除"
            self.delateView.alpha = 0.9
        }else {
            self.delateLabel.text = "拖至此处以删除"
            self.delateView.alpha = 0.7
        }
        
    }
    
    private func dragEnd(point: CGPoint) {
        //
        if point.y > self.view.frame.height - 100 - self.additionalSafeAreaInsets.bottom {
            self.imgsData.remove(at: self.indexPath.row)
            self.imgsURL.remove(at: self.indexPath.row)
            self.indexPath = IndexPath()
            self.imgCollection?.reloadData()
            self.DragedImg.image = UIImage()
            self.DragedImg.removeFromSuperview()
            self.delateViewShowOff()
        }else {
            self.indexPath = IndexPath()
            self.imgCollection?.reloadData()
            self.DragedImg.image = UIImage()
            self.DragedImg.removeFromSuperview()
            self.delateViewShowOff()
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    ///用于删除的View
    private func delateViewShowOn() {
        
        self.delateView.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: 300 + self.additionalSafeAreaInsets.bottom)
        self.delateView.backgroundColor = UIColor.dynamicColor(lightColor: .red, darkColor: .red)
        self.delateView.alpha = 0.7
        view.addSubview(self.delateView)
        
        self.delateView.addSubview(self.delateLabel)
        
        self.delateLabel.font = .boldSystemFont(ofSize: 20)
        self.delateLabel.adjustsFontSizeToFitWidth = true
        self.delateLabel.textAlignment = .center
        self.delateLabel.text = "拖至此处以删除"
        self.delateLabel.textColor = .white
        self.delateLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
            make.topMargin.equalTo(30)
        }
        
        UIView.animate(withDuration: 0.25) {
            self.delateView.frame = CGRect(x: 0, y: self.view.frame.height - 100 - self.additionalSafeAreaInsets.bottom, width: self.view.frame.width, height: 300 + self.additionalSafeAreaInsets.bottom)
        }
    }
    
    private func delateViewShowOff() {
        UIView.animate(withDuration: 0.25, animations: {
            self.delateView.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: 300 + self.additionalSafeAreaInsets.bottom)
        }) { (_) in
            self.delateView.removeFromSuperview()
        }
    }
    
}


extension addNewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    @objc private func getAlbumList() {
        let Alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let albumAction = UIAlertAction(title: "相册", style: .default) { (_) in
            self.album()
        }
        
        let tokePhotoAction = UIAlertAction(title: "照相", style: .default) { (_) in
            self.takePhoto()
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        Alert.addAction(albumAction)
        Alert.addAction(tokePhotoAction)
        Alert.addAction(cancelAction)
        self.present(Alert, animated: true, completion: nil)
    }
    
    private func album() {
        let albumPicker = UIImagePickerController()
        albumPicker.sourceType = .photoLibrary
        albumPicker.delegate = self
        albumPicker.allowsEditing = true
        self.present(albumPicker, animated: true, completion: nil)
    }
    
    private func takePhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraPicker = UIImagePickerController()
            cameraPicker.delegate = self
            cameraPicker.allowsEditing = true
            cameraPicker.sourceType = .camera
            self.present(cameraPicker, animated: true, completion: nil)
        }else{
            let alter = UIAlertController(title: "暂不支持拍照", message: "", preferredStyle: .alert)
            let action = UIAlertAction(title: "确定", style: .cancel, handler: nil)
            alter.addAction(action)
            self.present(alter, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("完成获取照片")
        
        let tokedPhoto = info[.editedImage] as! UIImage
        self.imgsData.insert(tokedPhoto, at: 0)
        
        if picker.sourceType == .camera {
//            //初始化一个标识符
            var localId: String!
            PHPhotoLibrary.shared().performChanges({
                let result = PHAssetChangeRequest.creationRequestForAsset(from: tokedPhoto)
                let assetPlaceHolder = result.placeholderForCreatedAsset
                //保存标志符
                localId = assetPlaceHolder?.localIdentifier
            }) { (isSuccessed, error) in
                if isSuccessed {
                    //获取保存图片的路径
                    print("保存拍照图片")

                    let assetResult = PHAsset.fetchAssets(withLocalIdentifiers: [localId], options: nil)
                    let asset = assetResult[0]

                    asset.requestContentEditingInput(with: PHContentEditingInputRequestOptions()) { (PHContentEditingInput, [AnyHashable : Any]) in
                        print("拍照存储地址", PHContentEditingInput?.fullSizeImageURL)
                        self.imgsURL.insert((PHContentEditingInput?.fullSizeImageURL)!, at: 0)
                    }
                }else {
                    print(error?.localizedDescription)
                }
            }
        }else if picker.sourceType == .photoLibrary {
            let imgURL = info[.imageURL] as! URL
            self.imgsURL.insert(imgURL, at: 0)
            
            
        }
        dismiss(animated: true) {
            self.imgCollection?.reloadData()
        }
    }
    
    
}
