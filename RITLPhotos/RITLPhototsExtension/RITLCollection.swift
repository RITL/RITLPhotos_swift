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

        let scale = UIScreen.main.scale
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        
        let options = PHImageRequestOptions()
        options.deliveryMode = mode
        options.isNetworkAccessAllowed = true
        
        //图片请求
        PHCachingImageManager.default().requestImage(for: lastResult, targetSize: newSize, contentMode: .aspectFill, options: options) { (image, info) in
            
            complete(self.localizedTitle, assetResult.count, image)
        }
    }
}


