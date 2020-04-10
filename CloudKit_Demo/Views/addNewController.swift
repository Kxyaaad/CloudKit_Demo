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

class addNewController: UIViewController {
    
    var textInput : UITextView?
    
    var imgCollection : UICollectionView?
    
    var imgsData : Array<UIImage> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        // Do any additional setup after loading the view.
    }
    
    private func setUpUI() {
        view.backgroundColor = UIColor.init(dynamicProvider: { (TC) -> UIColor in
            switch TC.userInterfaceStyle{
            case .dark:
                return UIColor.init(white: 0.1, alpha: 1)
            case .light:
                return UIColor.init(white: 0.9, alpha: 1)
            case .unspecified:
                return UIColor.init(white: 0.9, alpha: 1)
            default:
                return UIColor.init(white: 0.9, alpha: 1)
            }
        })
        
        //输入框
        self.textInput = UITextView()
        self.textInput?.font = .systemFont(ofSize: 15)
        self.textInput?.layer.cornerRadius = 10
        self.textInput?.delegate = self
        self.textInput?.backgroundColor = UIColor.init(dynamicProvider: { (TC) -> UIColor in
            switch TC.userInterfaceStyle{
            case .dark:
                return UIColor.init(white: 0, alpha: 1)
            case .light:
                return UIColor.init(white: 1, alpha: 1)
            case .unspecified:
                return UIColor.init(white: 1, alpha: 1)
            default:
                return UIColor.init(white: 1, alpha: 1)
            }
        })
        view.addSubview(self.textInput!)
       
        self.textInput?.frame = CGRect(origin: CGPoint(x: 20, y: 20), size: CGSize(width: self.view.frame.width-40, height: 200))
        
        //选择图片
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 50, height: 50)
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets.init(top: 5, left: 5, bottom: 5, right: 5)
        
        self.imgCollection = UICollectionView(frame: CGRect(origin: CGPoint(x: 20, y: 240), size: CGSize(width: self.view.frame.width - 40, height: 400)), collectionViewLayout: layout)
        self.imgCollection?.delegate = self
        self.imgCollection?.dataSource = self
        self.imgCollection?.register(pickImageCell.self, forCellWithReuseIdentifier: "PICKIMAGE")
        
        
        
        self.imgCollection?.setCollectionViewLayout(layout, animated: true)
        
        self.imgCollection?.backgroundColor = UIColor.init(dynamicProvider: { (TC) -> UIColor in
            switch TC.userInterfaceStyle{
            case .dark:
                return UIColor.init(white: 0, alpha: 1)
            case .light:
                return UIColor.init(white: 1, alpha: 1)
            case .unspecified:
                return UIColor.init(white: 1, alpha: 1)
            default:
                return UIColor.init(white: 1, alpha: 1)
            }
        })
        view.addSubview(self.imgCollection!)
        
    }
    
    
    @objc
    private func test() {
        print("test")
        
        //新建
        let artworkRecordID = CKRecord.ID(recordName: "116")
        let artworkRecord = CKRecord(recordType: "TestType", recordID: artworkRecordID)
        artworkRecord["name"] = "Harrt" as NSString
        
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
            cell.touchBtn?.setBackgroundImage(UIImage.init(named: "tianjiatupian"), for: [])
//            cell.touchBtn?.addTarget(self, action: #selector(getAlbumList), for: .touchUpInside)
        }else {
            cell.touchBtn?.setBackgroundImage(self.imgsData[indexPath.row], for: [])
//            cell.touchBtn?.removeTarget(self, action: #selector(getAlbumList), for: .touchUpInside)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == self.imgsData.count{
            self.getAlbumList()
        }
    }
    
}


extension addNewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    @objc private func getAlbumList() {
        let Alert = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
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
        self.imgsData.append(tokedPhoto)
        if picker.sourceType == .camera {
            UIImageWriteToSavedPhotosAlbum(tokedPhoto, self, nil, nil)
        }
        dismiss(animated: true) {
            self.imgCollection?.reloadData()
        }
    }
    
   
}
