//
//  extension.swift
//  CloudKit_Demo
//
//  Created by Mac on 2020/4/21.
//  Copyright © 2020 Mac. All rights reserved.
//

import Foundation
import UIKit
import NotificationCenter


extension UIColor {
    class func dynamicColor (lightColor: UIColor, darkColor:UIColor) -> UIColor {
        let color = UIColor.init { (TC) -> UIColor in
            switch TC.userInterfaceStyle {
            case .dark:
                return darkColor
            case .light:
                return lightColor
            case .unspecified:
                return lightColor
            default:
                return lightColor
            }
        }
        return color
    }
    
    
}


