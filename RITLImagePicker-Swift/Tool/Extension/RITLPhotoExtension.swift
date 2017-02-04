//
//  RITLPhotoExtension.swift
//  RITLImagePicker-Swift
//
//  Created by YueWen on 2017/1/20.
//  Copyright © 2017年 YueWen. All rights reserved.
//

import Foundation
import UIKit
import ObjectiveC


struct RITLPhotosAssociate
{
    
    static let RITL_ControlHandleValue = UnsafeRawPointer(bitPattern: "RITL_ControlHandleValue".hashValue)
    static let RITL_GestureHandleValue = UnsafeRawPointer(bitPattern: "RITL_GestureHandleValue".hashValue)
}



extension UIColor {
    
    /// 生成图片
    public var ritl_image : UIImage {
        
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


extension Int {
    
    /// 将数据大小变为格式字符串
    public var ritl_dataSize : String {
        
        guard self > 0 else {
            
            return ""
        }
        
        let unit = 1024.0
        
        guard Double(self) < unit * unit else {
            
            return String(format:"%.1fMB",Double(self) / unit / unit)
        }
        
        guard Double(self) < unit else {
            
            return String(format:"%.0fKB",Double(self) / unit)
        }
        
        return "\(self)B"
    }
    
    
    
    /// 16进制数值获得颜色
    public var ritl_color : UIColor {
        
        guard self < 0 else {
            
            return UIColor.black
        }
        
        let red = (CGFloat)((self & 0xFF0000) >> 16) / 255.0
        let green = (CGFloat)((self & 0xFF00) >> 8) / 255.0
        let blue = (CGFloat)((self & 0xFF)) / 255.0
        
        
        if #available(iOS 10, *)
        {
            return UIColor(displayP3Red:red , green: green, blue: blue, alpha: 1.0)
        }
        
        guard #available(iOS 10, *) else {
            
            return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
        }
        
        return UIColor.black
    }
}




extension TimeInterval {

    /// 将时间戳转换为当前的总时间，格式为00:00:00
    public var ritl_time : String {
        
        let time : UInt = UInt(self)
        
        guard time < 60 * 60 else {
            
            let hour = String(format: "%.2d",time / 60 / 60)
            let minute = String(format: "%.2d",time % 3600 / 60)
            let second = String(format: "%.2d",time % (3600 * 60))
            
            return "\(hour):\(minute):\(second)"
        }
        
        
        guard time < 60 else {
            
            let minute = String(format:"%.2d",time / 60)
            let second = String(format:"%.2d",time % 60)
            
            return "\(minute):\(second)"
        }
        
        
        return "00:\(String(format:"%.2d",time))"
    }
}



// MARK: Control

typealias RITLControlActionClosure = ((UIControl)->Void)

extension UIControl
{
    
    // MARK: public
    func action(at state:UIControlEvents,handle:RITLControlActionClosure?)
    {
        guard let actionHandle = handle else { return }
        
        objc_setAssociatedObject(self, RITLPhotosAssociate.RITL_ControlHandleValue, actionHandle, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
        
        self.addTarget(self, action: #selector(UIControl.ritl_actionHandle), for: state)
        
        
    }
    
    
    // MARK: private
    @objc fileprivate func ritl_actionHandle()
    {
        guard let actionHandle = objc_getAssociatedObject(self, RITLPhotosAssociate.RITL_ControlHandleValue) else { return }
        
        (actionHandle as! RITLControlActionClosure)(self)
        
    }
    
}



typealias RITLGestureClosure = ((UIGestureRecognizer) -> Void)

extension UIGestureRecognizer
{
    
    /// 用于替代目标动作回调的方法
    ///
    /// - Parameter handle: 执行的闭包
    func action(_ handle:RITLGestureClosure?)
    {
        guard let handle = handle else {
            
            return
        }
        
        //缓存
        objc_setAssociatedObject(self, RITLPhotosAssociate.RITL_GestureHandleValue, handle, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
        
        //添加
        self.addTarget(self, action: #selector(UIGestureRecognizer.ritl_actionHandle))
    }
    
    
    @objc fileprivate func ritl_actionHandle()
    {
        //执行
        (objc_getAssociatedObject(self, RITLPhotosAssociate.RITL_GestureHandleValue) as! RITLGestureClosure)(self)

    }
}



// MARK: UIViewController

extension UIViewController
{
    
    /// 弹出alert控制器
    ///
    /// - Parameter count: 限制的数目
    func present(alertControllerShow count:UInt)
    {
        let alertController = UIAlertController(title: ("你最多可以选择\(count)张照片"), message: nil, preferredStyle: UIAlertControllerStyle.alert)
        
        alertController.addAction(UIAlertAction(title: "知道了", style: UIAlertActionStyle.cancel, handler: { (action) in
            
        }))
        
        present(alertController, animated: true, completion: nil)
    }
}



// MARK: Deprecated


//// MARK: Color
//
//extension UIColor
//{
//    
//    /// 根据16进制数字转换成Color
//    ///
//    /// - Parameter rgbValue: 16进制的RGB
//    /// - Returns: 创建好的Color
//    @available(iOS, deprecated:8.0, message: "Use Int.ritl_color instead")
//    static func colorValue(with rgbValue:Int) -> UIColor?
//    {
//        let red = (CGFloat)((rgbValue & 0xFF0000) >> 16) / 255.0
//        let green = (CGFloat)((rgbValue & 0xFF00) >> 8) / 255.0
//        let blue = (CGFloat)((rgbValue & 0xFF)) / 255.0
//        
//        
//        if #available(iOS 10, *)
//        {
//            return UIColor(displayP3Red:red , green: green, blue: blue, alpha: 1.0)
//        }
//        
//        guard #available(iOS 10, *) else {
//            
//            return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
//        }
//        
//        return nil
//    }
//}
//
//
//
//
///// 将数据大小变为格式字符串
/////
///// - Parameter dataSize: 数据的大小
///// - Returns: 创建完毕的字符串
//@available (iOS, deprecated:8.0, message: "Use Int.ritl_dataSize instead")
//public func ritl_dataSize(_ dataSize:Int) -> String
//{
//    
//    guard dataSize > 0 else {
//        
//        return ""
//    }
//    
//    let unit = 1024.0
//    
//    guard Double(dataSize) < unit * unit else {
//        
//        return String(format:"%.1fMB",Double(dataSize) / unit / unit)
//    }
//    
//    guard Double(dataSize) < unit else {
//        
//        return String(format:"%.0fKB",Double(dataSize) / unit)
//    }
//    
//    return "\(dataSize)B"
//}
//
//
///// 将时间戳转换为当前的总时间，格式为00:00:00
/////
///// - Parameter timeDuration: 转换的时间戳
///// - Returns: 转换后的格式化字符串
//@available(iOS, deprecated:8.0, message: "Use TimeInterval.ritl_time instead")
//public func ritl_timeFormat(_ timeDuration:TimeInterval) -> String
//{
//    let time : UInt = UInt(timeDuration)
//    
//    guard time < 60 * 60 else {
//        
//        let hour = String(format: "%.2d",time / 60 / 60)
//        let minute = String(format: "%.2d",time % 3600 / 60)
//        let second = String(format: "%.2d",time % (3600 * 60))
//        
//        return "\(hour):\(minute):\(second)"
//    }
//    
//    
//    guard time < 60 else {
//        
//        let minute = String(format:"%.2d",time / 60)
//        let second = String(format:"%.2d",time % 60)
//        
//        return "\(minute):\(second)"
//    }
//    
//    
//    return "00:\(String(format:"%.2d",time))"
//}
//
//
//
///// 根据颜色生成图片
/////
///// - Parameter color: 生成图片的颜色
///// - Returns: 创建完毕的图片
//@available(iOS, deprecated:8.0, message: "Use UIColor.ritl_image instead")
//public func ritl_image(in color:UIColor) -> UIImage
//{
//    let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
//    
//    UIGraphicsBeginImageContext(rect.size)
//    
//    let context = UIGraphicsGetCurrentContext()
//    context?.setFillColor(color.cgColor)
//    context?.fill(rect)
//    
//    let image = UIGraphicsGetImageFromCurrentImageContext()
//    UIGraphicsEndImageContext()
//    
//    return image!
//}
