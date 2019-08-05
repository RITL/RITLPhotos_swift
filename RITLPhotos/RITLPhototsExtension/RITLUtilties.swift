//
//  RITLUtilties.swift
//  RITLImagePicker-Swift
//
//  Created by YueWen on 2019/8/1.
//  Copyright © 2019 YueWen. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit

//MARK: BarHeight

/// tab的具体
public enum RITLPhotosBarDistance {
    case NavigationBar
    case TabBar
}


extension RITLPhotosBarDistance {
    
    /// 正常情况下的高度
    var normalHeight: CGFloat {
        switch self {
        case .NavigationBar:
            return 64
        case .TabBar:
            return 49
        }
    }
    
    /// 默认高度
    var height: CGFloat {
        switch self {
        case .NavigationBar:
            return hasPhoneHeader() ? 88 : 64
        case .TabBar:
            return hasPhoneHeader() ? 83 : 49
        }
    }
    
    /// 安全间隔
    var safeDistance: CGFloat {
        switch self {
        case .NavigationBar:
            return hasPhoneHeader() ? 88 - 64 : 0
        case .TabBar:
            return hasPhoneHeader() ? 83 - 64 : 0
        }
    }
}



/// 字体
enum RITLPhotosFont: String {
    
    case regular = "PingFangSC-Regular"
    case medium = "PingFangSC-Medium"
    case bold = "PingFangSC-Bold"
    case light = "PingFangSC-Light"
    case semibold = "PingFangSC-Semibold"
}


extension RITLPhotosFont {
    func font(size: CGFloat) -> UIFont {
        return UIFont.safe_font(name: self.rawValue, size: size)
    }
}


extension UIFont {
    
    /// 根据字体名字获取font对象，如果不存在，返回系统默认字体
    ///
    /// - Parameters:
    ///   - name: 字体类型
    ///   - size: 字体大小
    public class func safe_font(name: String, size: CGFloat) -> UIFont{
        if let font = UIFont(name: name, size: size) {
            return font
        }
        return UIFont.systemFont(ofSize: size)
    }
}



//MARK: 适配X
/// 是否存在刘海平
public func hasPhoneHeader() -> Bool {
    
    let headerPhones = [CGSize(width: 375, height: 812),
                        CGSize(width: 414, height: 896)]
    
    return headerPhones.contains(UIScreen.main.bounds.size)
}

