//
//  dynamicColor.swift
//  CloudKit_Demo
//
//  Created by Mac on 2020/4/13.
//  Copyright © 2020 Mac. All rights reserved.
//

import Foundation
import UIKit
import CloudKit


let ScreenWidth = UIScreen.main.bounds.width
let ScreenHeight = UIScreen.main.bounds.height



///用户登录成功通知
let UserLoginSuccessedNotification = "UserLoginSuccessedNotification"

///发布后通知刷新
let UpdataBlogNotification = "UpdataBlogNotification"

func archiverCursor(original:CKQueryOperation.Cursor) -> Data {
    let archiver = NSKeyedArchiver.init(requiringSecureCoding: false)
    original.encode(with: archiver)
    archiver.finishEncoding()
    return archiver.encodedData
}

func unArchiverCursor(data:Data) -> CKQueryOperation.Cursor {
    let unarchiver = try? NSKeyedUnarchiver.init(forReadingFrom: data)
    let cursor = CKQueryOperation.Cursor(coder: unarchiver!)
    return cursor!
}
