//
//  RITLPhotoBridgeManager.swift
//  RITLImagePicker-Swift
//
//  Created by YueWen on 2017/1/19.
//  Copyright © 2017年 YueWen. All rights reserved.
//

import UIKit
import Photos

/// 进行桥接进行回调的Manager
class RITLPhotoBridgeManager: NSObject
{
    /// 单例对象
    static let sharedInstance = RITLPhotoBridgeManager()
    
    /// 获取图片之后的闭包
    var completeUsingImage:(([UIImage]) -> Void)?
    
    /// 获取图片数据之后的闭包
    var completeUsingData:(([Data]) -> Void)?
    
    /// 开始获取图片以及数据
    ///
    /// - Parameter assets: 选中的资源对象
    func start(renderFor assets:[PHAsset])
    {
        // 渲染图片的大小
        let size = RITLPhotoCacheManager.sharedInstance.imageSize
        
        // 如果为原图，忽略size
        let isIgnore = size.width < 0
        
        // 是否高清图
        let isHightQuarity = RITLPhotoCacheManager.sharedInstance.isHightQuarity
        
        RITLPhotoRequestStore.startRequestImage(imagesIn: assets, isHight: isHightQuarity, size: size, ignoreSize: isIgnore) { (images) in
            
            self.completeUsingImage?(images)
            
        }
        
        //请求数据
        RITLPhotoRequestStore.startRequestData(imagesIn: assets, isHight: isHightQuarity) { (datas) in
            
            self.completeUsingData?(datas)
        }

    }
}
