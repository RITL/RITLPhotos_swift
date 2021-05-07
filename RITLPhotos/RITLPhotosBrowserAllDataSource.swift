//
//  RITLPhotosBrowserAllDataSource.swift
//  RITLImagePicker-Swift
//
//  Created by YueWen on 2021/4/27.
//  Copyright © 2021 YueWen. All rights reserved.
//

import UIKit
import Photos

/// 所有数据的数据源
public final class RITLPhotosBrowserAllDataSource: NSObject, RITLPhotosBrowserDataSource {

    /// 进入预览组的集合
    var collection = PHAssetCollection() {
        didSet {
            let options = PHFetchOptions()
            options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            assetResult = PHAsset.fetchAssets(in: collection, options: options)
        }
    }
    /// 当前点击进入的资源对象
    var asset = PHAsset()
    /// 存储资源的对象
    private(set) var assetResult = PHFetchResult<PHAsset>()
    /// 资源化的manager
    private(set) var imageManager: PHCachingImageManager = PHCachingImageManager()
    
    
    //MARK: RITLPhotosBrowserDataSource
    func asset(at indexPath: IndexPath) -> PHAsset? {
        guard indexPath.item < assetResult.count else { return nil }
        return assetResult.object(at: indexPath.item)
    }
    
    func defaultIndexPath() -> IndexPath {
        guard assetResult.contains(asset) else { return IndexPath(item: 0, section: 0) }
        ritl_p_print(assetResult.index(of: asset))
        return IndexPath(item: assetResult.index(of: asset), section: 0)
    }
    
    deinit {
        ritl_p_print("\(type(of: self)) is deinit")
    }
}

extension RITLPhotosBrowserAllDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assetResult.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //获得cell
        let asset = assetResult.object(at: indexPath.item)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: asset.cellIdentifier().rawValue, for: indexPath)
        
        if let cell = cell as? RITLPhotosBrowserUpdater {
            cell.update(asset: asset, at: indexPath, imageManager: imageManager)
        }
        
        return cell
    }
    
}
