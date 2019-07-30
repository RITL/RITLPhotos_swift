//
//  RITLStoryboard.swift
//  RITLImagePicker-Swift
//
//  Created by YueWen on 2019/7/30.
//  Copyright © 2019 YueWen. All rights reserved.
//

import Foundation
import UIKit


extension Bundle {
    
    /// RITLPhotos 的主 Bundle
    static func ritl_MainBunle() -> Bundle {
        return Bundle(for: RITLPhotosViewController.self)
    }
}



/// RITLPhotos 的各大界面控制器
enum RITLViewControllers: String {
    /// 相册组
    case group = "RITLPhotosGroupTableViewController"
    /// 集合
    case collection
    /// 浏览
    case borwse
}



fileprivate extension UIStoryboard {
    
    /// RITLPhotos 的 storyboard 的初始化控制器
    ///
    /// - Parameter name: stroyboard的名称
    /// - Returns: 当前storyboard的初始化控制器
    static func ritl_instantiateInitialViewController(stroyboard name: String) -> UIViewController? {
        return UIStoryboard(name: name, bundle: Bundle.ritl_MainBunle()).instantiateInitialViewController()
    }
    
}

extension RITLViewControllers {
    
    /// 控制器
    func viewController() -> UIViewController {
        return  UIStoryboard.ritl_instantiateInitialViewController(stroyboard: self.rawValue) ?? UIViewController()
    }
}



