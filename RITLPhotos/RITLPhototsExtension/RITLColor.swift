//
//  RITLColor.swift
//  RITLImagePicker-Swift
//
//  Created by YueWen on 2019/8/1.
//  Copyright © 2019 YueWen. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    /// 生成图片
    public var ritlPhoto_image : UIImage {
        
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(self.cgColor)
        context?.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
}
