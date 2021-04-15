//
//  RITLPhotosUtilites.swift
//  RITLImagePicker-Swift
//
//  Created by YueWen on 2021/4/14.
//  Copyright © 2021 YueWen. All rights reserved.
//

import UIKit


extension UIColor {
    
    /// 生成图片
    public var ritl_p_image : UIImage {
        
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(self.cgColor)
        context?.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
    
    
    /// 混合色，默认0.5为中间色
    
    
    /// 混合色,不合规返回.white
    /// - Parameters:
    ///   - color: 第二种颜色
    ///   - percent: 默认0.5为中间色, color参数的比例
    public func ritl_p_blend(color: UIColor = .white, percent: Double = 0.5) -> UIColor {
        
        //自己的色值
        let fromRed = UnsafeMutablePointer<CGFloat>.allocate(capacity: 1)
        let fromGreen = UnsafeMutablePointer<CGFloat>.allocate(capacity: 1)
        let fromBlue = UnsafeMutablePointer<CGFloat>.allocate(capacity: 1)
        let fromAlpha = UnsafeMutablePointer<CGFloat>.allocate(capacity: 1)
        
        defer {
            fromRed.deallocate()
            fromGreen.deallocate()
            fromBlue.deallocate()
            fromAlpha.deallocate()
        }
        
        if !getRed(fromRed, green: fromGreen, blue: fromBlue, alpha: fromAlpha) {
            return .white
        }
        
        //Ro
        let toRed = UnsafeMutablePointer<CGFloat>.allocate(capacity: 1)
        let toGreen = UnsafeMutablePointer<CGFloat>.allocate(capacity: 1)
        let toBlue = UnsafeMutablePointer<CGFloat>.allocate(capacity: 1)
        let toAlpha = UnsafeMutablePointer<CGFloat>.allocate(capacity: 1)
        
        
        defer {
            toRed.deallocate()
            toGreen.deallocate()
            toBlue.deallocate()
            toAlpha.deallocate()
        }
        
        if !color.getRed(toRed, green: toGreen, blue: toBlue, alpha: toAlpha) {
            return .white
        }
        
        //计算
        let newRed = fromRed.pointee + (toRed.pointee - fromRed.pointee) * CGFloat(fmin(1, percent))
        let newGreen = fromGreen.pointee + (toGreen.pointee - fromGreen.pointee) * CGFloat(fmin(1, percent))
        let newBlue = fromBlue.pointee + (toBlue.pointee - fromBlue.pointee) * CGFloat(fmin(1, percent))
        let newAlpha = fromAlpha.pointee + (toAlpha.pointee - fromAlpha.pointee) * CGFloat(fmin(1, percent))
        
        return UIColor(red: newRed, green: newGreen, blue: newBlue, alpha: newAlpha)
    }
}


extension Int{
    
    /// 生成颜色
    public var ritl_p_color: UIColor {
        
        if self < 0 { return .black }
        let color = self.ritl_p_colorBrightness
        return UIColor(red: color, green: color, blue: color, alpha: 1)
    }
    
    /// 生成图片
    public var ritl_p_image : UIImage {
        return self.ritl_p_color.ritl_p_image
    }
    
    
    /// 颜色的色值，self/255.0
    public var ritl_p_colorBrightness: CGFloat {
        
        if self < 0 || self > 255 { return 0 }
        return CGFloat(self) / 255
    }

    
    /// 生成size
    public var ritl_p_size: CGSize {
        guard self > 0 else { return .zero }
        return CGSize(width: self, height: self)
    }
}



