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


extension RITLPhotosBrowserUpdater where Self: RITLPhotosBrowserVideoCollectionCell {
    
    public func play() {
        guard let asset = asset, asset.mediaType == .video else { return }
        //如果player存在直接播放即可
        if let playerLayer = self.player, let player = playerLayer.player {
            player.play(); return
        }
        //请求播放
        let options = PHVideoRequestOptions()
        options.deliveryMode = .automatic
        //开始获取
        PHImageManager.default().requestPlayerItem(forVideo: asset, options: options) { item, info in
            guard let item = item else { return }
            DispatchQueue.main.async {
                
                let player = AVPlayer(playerItem: item)
                let playerLayer = AVPlayerLayer(player: player)
                self.player = playerLayer
                
                //Notification
                NotificationCenter.default.addObserver(self, selector: #selector(self.stopNotification), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: item)
                
                //config
                playerLayer.videoGravity = .resizeAspect
                playerLayer.frame = self.iconImageView.layer.bounds
                self.playerImageView.isHidden = true
                self.iconImageView.layer.addSublayer(playerLayer)
                
                //发送通知
                NotificationCenter.default.post(name: RITLPhotosBrowserTapNotificationName, object: self, userInfo: [String.RITLPhotosBrowserVideoTapNotificationHiddenKey : true])
                //播放
                player.play()
            }
        }
    }
    
    
    public func stop() {
        guard let playLayer = self.player, let player = playLayer.player else { return }
        //发送通知
        NotificationCenter.default.post(name: RITLPhotosBrowserTapNotificationName, object: nil, userInfo: [String.RITLPhotosBrowserVideoTapNotificationHiddenKey : false])
        player.pause()
        playLayer.removeFromSuperlayer()
        NotificationCenter.default.removeObserver(self)
        playerImageView.isHidden = false
        self.player = nil
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


public extension RITLPhotosBrowserResetter where Self: RITLPhotosBrowserVideoCollectionCell {
    
    func reset() {
        stop()
    }
}


public extension RITLPhotosBrowserResetter where Self: RITLPhotosBrowserLiveCollectionCell {
    
    func reset() {
        stop()
    }
}
