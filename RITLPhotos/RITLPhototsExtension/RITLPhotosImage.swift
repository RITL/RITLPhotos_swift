//
//  Bundle+RITLPhotos.swift
//  RITLImagePicker-Swift
//
//  Created by YueWen on 2019/7/30.
//  Copyright © 2019 YueWen. All rights reserved.
//

import Foundation
import UIKit

fileprivate extension Bundle {
    
    /// RITLPhotos 的主 Bundle
    static func ritl_MainBunle() -> Bundle {
        return Bundle(for: RITLPhotosViewController.self)
    }
}



fileprivate extension Bundle {

    ///RITLImagePicker-Swift的bundle
    static func ritl_bundle() -> Bundle? {
        
        guard let bundlePath = Bundle.ritl_MainBunle().path(forResource: "RITLPhotos", ofType: "bundle") else {
            return nil
        }
        return Bundle(path: bundlePath)
    }
}


fileprivate extension String {
    
    func ritl_bundleImage() -> UIImage? {
        /// 获得本地资源bundle路径
        guard let path = Bundle.ritl_bundle()?.resourcePath else { return nil }
        return UIImage(contentsOfFile: "\(path)/\(self)")
    }
}


/// RITLPhotos 使用的图片
enum RITLPhotosImage: String {
    
    //相册组
    
    /// 占位图
    case placeholder = "ritl_placeholder.png"
    /// 右侧的箭头
    case arrowRight = "ritl_arrow_right.png"
    
    //集合视图
    
    /// 集合视图
    case deselect = "ritl_deselect.png"
    
    //浏览视图
    
    /// 浏览右上角的选中
    case browerSelect = "ritl_brower_selected.png"
    /// 浏览左上角的返回
    case browseBack = "ritl_browse_back.png"
    /// 浏览下方原图选中
    case borwseBottomSelecte = "ritl_bottomSelected.png"
    /// 浏览下方原图未选中
    case borwseBottomDeselecte = "ritl_bottomUnselected.png"
    /// 视频播放
    case videoPlayer = "ritl_video_play.png"
}

extension RITLPhotosImage {
    
    /// RITLPhotos 
    func image() -> UIImage? {
        return self.rawValue.ritl_bundleImage()
    }
}
