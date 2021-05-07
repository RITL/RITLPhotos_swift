//
//  RITLPhotosBrowserPreviewDataSource.swift
//  RITLImagePicker-Swift
//
//  Created by YueWen on 2021/5/7.
//  Copyright © 2021 YueWen. All rights reserved.
//

import UIKit
import Photos

/// 浏览数据的数据源
public class RITLPhotosBrowserPreviewDataSource: NSObject,RITLPhotosBrowserDataSource {

    /// 资源对象
    var assets = [PHAsset]()
    /// 资源化的manager
    private(set) var imageManager: PHCachingImageManager = PHCachingImageManager()
    
    
    //MARK: <RITLPhotosBrowserDataSource>
    func asset(at indexPath: IndexPath) -> PHAsset? {
        guard indexPath.item < assets.count else { return nil }
        return assets[indexPath.item]
    }
    
    //MARK: <UICollectionViewDataSource>
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //获得cell
        let asset = assets[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: asset.cellIdentifier().rawValue, for: indexPath)
        
        if let cell = cell as? RITLPhotosBrowserUpdater {
            cell.update(asset: asset, at: indexPath, imageManager: imageManager)
        }
        
        return cell
    }
    
    deinit {
        ritl_p_print("\(type(of: self)) is deinit")
    }
}
