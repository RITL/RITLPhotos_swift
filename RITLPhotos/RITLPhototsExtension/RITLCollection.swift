//
//  RITLCollection.swift
//  RITLImagePicker-Swift
//
//  Created by YueWen on 2019/7/30.
//  Copyright © 2019 YueWen. All rights reserved.
//

import Foundation
import UIKit
import Photos

private struct RITLCollectionMakerCache {
    
    /// 静态对象
    static var share = RITLCollectionMakerCache()
    /// 缓存
    private var cache = [String: UIImage]()
    
    /// 缓存数据
    static func insert(key: String, image: UIImage?){
        guard let image = image else { return }
        share.cache.updateValue(image, forKey: key)
    }
    
    /// 获得缓存的图片
    static func image(for key: String) -> UIImage? {
        return share.cache[key]
    }
    
    /// 删除所有
    static func moveAll(){
        share.cache.removeAll()
    }
}


protocol RITLCollectionMaker {
    
    /// 转成图片
    func image(size: CGSize,
               mode: PHImageRequestOptionsDeliveryMode,
               complete:((String,Int,UIImage) -> ()))
}


extension RITLCollectionMaker {

    func image(size: CGSize,
               mode: PHImageRequestOptionsDeliveryMode,
               complete:((String,Int,UIImage) -> ())){}
}



extension PHAssetCollection: RITLCollectionMaker { }
extension RITLCollectionMaker where Self: PHAssetCollection {
    
    func image(size: CGSize,
               mode: PHImageRequestOptionsDeliveryMode,
               complete:@escaping ((String?,Int,UIImage?) -> ())) {
        //获得图片对象
        guard let assetResult = PHAsset.fetchKeyAssets(in: self, options: nil),assetResult.count > 0, let lastResult = assetResult.lastObject else {
            complete(localizedTitle, 0, nil); return
        }
        
        //查询缓存
        if let cacheImage = RITLCollectionMakerCache.image(for: "\(lastResult.localIdentifier)_group")  {
            complete(self.localizedTitle, assetResult.count, cacheImage); return
        }

        let scale = UIScreen.main.scale
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        
        let options = PHImageRequestOptions()
        options.deliveryMode = mode
        options.isNetworkAccessAllowed = true
        
        //图片请求
        PHCachingImageManager.default().requestImage(for: lastResult, targetSize: newSize, contentMode: .aspectFill, options: options) { (image, info) in
            
            RITLCollectionMakerCache.insert(key: "\(lastResult.localIdentifier)_group", image: image)//插入
            complete(self.localizedTitle, assetResult.count, image)
        }
    }
}


