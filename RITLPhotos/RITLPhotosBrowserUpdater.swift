//
//  RITLPhotosBrowserUpdater.swift
//  RITLImagePicker-Swift
//
//  Created by YueWen on 2021/4/28.
//  Copyright © 2021 YueWen. All rights reserved.
//

import Foundation
import Photos

///
public protocol RITLPhotosBrowserUpdater {
    /// 更新数据
    func update(asset: PHAsset, at indexPath: IndexPath, imageManager: PHCachingImageManager)
    /// 播放
    func play()
    /// 停止
    func stop()
}

public extension RITLPhotosBrowserUpdater {
    
    func update(asset: PHAsset, at indexPath: IndexPath, imageManager: PHCachingImageManager) {}
    func play() {}
    func stop() {}
}



public extension RITLPhotosBrowserUpdater where Self: RITLPhotosBrowserCollectionCell {
    
    func update(asset: PHAsset, at indexPath: IndexPath, imageManager: PHCachingImageManager) {
        //记录
        assetIdentifer = asset.localIdentifier
        self.asset = asset
        //请求图片
        imageManager.requestImage(for: asset, targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight), contentMode: .aspectFill, options: PHImageRequestOptions()) { (image, _) in
            
            guard asset.localIdentifier == self.assetIdentifer else { return }
            self.iconImageView.image = image
            self.iconImageSetComplete()
        }
    }
}


extension RITLPhotosBrowserUpdater where Self: RITLPhotosBrowserLiveCollectionCell {
    
    // 播放几颗
    func play() {
        if #available(iOS 9.1, *) {
            guard let asset = asset, asset.mediaSubtypes == .photoLive else { return }
            layoutIfNeeded()
            
            let options = PHLivePhotoRequestOptions()
            options.deliveryMode = .highQualityFormat
            //请求图片
            PHImageManager.default().requestLivePhoto(for: asset, targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight), contentMode: .aspectFill, options: options) { livePhoto, _ in
                //图片
                guard let livePhoto = livePhoto else { return }
                //设置
                self.livePhotoView.livePhoto = livePhoto
                //播放即可
                guard !self.isPlaying else { return }
                //播放
                self.livePhotoView.startPlayback(with: .hint)
            }
        }
    }
    
    func stop() {
        guard isPlaying else { return }
        if #available(iOS 9.1, *) {
            livePhotoView.stopPlayback()
        }
    }
}


public protocol RITLPhotosBrowserResetter {
    /// 用于图片恢复
    func reset()
}

public extension RITLPhotosBrowserResetter {
    func reset() {}
}


public extension RITLPhotosBrowserResetter where Self: RITLPhotosBrowserNormalCollectionCell {
    
    func reset() {
        scrollView.maximumZoomScale = 2.0
        scrollView.setZoomScale(1.0, animated: false)
    }
}
