//
//  RITLPhotoStore.swift
//  RITLImagePicker-Swift
//
//  Created by YueWen on 2021/4/14.
//  Copyright © 2021 YueWen. All rights reserved.
//

import UIKit
import Photos

typealias RITLPhotosAuthorizationHandler = (_ authorization: PHAuthorizationStatus)->()

/// 类型
struct RITLPhotosAlbumItem<Type,Element> {
    /// 存储的数据
    var data: Type? = nil
    /// 存储的数组数据
    var datas: [Element] = []
}



extension PHPhotoLibrary {
    
    
    /// 获取所有的照片分组
    /// - Parameters:
    ///   - autoSort: 是否启用默认的排序，如果是Array则会进行排序
    ///   - needTopLevel: 是否获得topLevel的相册组
    ///   - hasDefalutHandler: 是否进行默认的处理，比如最近删除等分组将不再返回
    ///   - complete: 获得分组完成，如果权限无法获取，则不进行该回调
    ///   - authorizationDeniedHandler: 权限回调
    func fetchAlbumGroups(autoSort: Bool = false,
                          needTopLevel: Bool = false,
                          hasDefalutHandler: Bool = true,
                          complete: ((_ regular: RITLPhotosAlbumItem<PHFetchResult<PHAssetCollection>,PHAssetCollection>,
                                      _ topLeve: RITLPhotosAlbumItem<PHFetchResult<PHCollection>,PHCollection>?)->())? = nil,
                          authorizationHandler: RITLPhotosAuthorizationHandler? = nil) {
        
        //权限检测
        PHPhotoLibrary.authorizationCheck { (status) in
            //进行权限回调
            authorizationHandler?(status)
            //获得regular的数据
            let options = PHFetchOptions()
//            options.includeHiddenAssets = false
//            options.includeAllBurstAssets = false
            options.sortDescriptors = [NSSortDescriptor(key: "endDate", ascending: false)]
            let smartAlum = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: options)
            //进行数据转换
            var smartAlums = RITLFetchResultTransformer.toArray(result: smartAlum).filter{ PHAsset.fetchAssets(in: $0, options: nil).count > 0 }
            //如果需要排序，进行排序
            if (autoSort) {
                smartAlums = smartAlums.ritl_p_defalutSort()
            }
            //将最近删除屏蔽
            smartAlums = smartAlums.filter{
                $0.assetCollectionSubtype != .smartAlbumAllHidden
                && $0.assetCollectionSubtype .rawValue != 1000000201 //最近删除
            }
            //生成regularItem
            let regularItem = RITLPhotosAlbumItem(data: smartAlum, datas: smartAlums)
            //如果不需要直接返回即可
            guard needTopLevel else {
                complete?(regularItem, nil); return
            }
            
            //获得自定义相册组
            let topLevelAlum = PHCollection.fetchTopLevelUserCollections(with: options)
            let topLevelAlums = RITLFetchResultTransformer.toArray(result: topLevelAlum).filter{(collection) in
                guard let collection = collection as? PHAssetCollection else {
                    return false
                }
                return PHAsset.fetchAssets(in: collection, options: nil).count > 0
            }
            let topLevelItem = RITLPhotosAlbumItem(data: topLevelAlum, datas: topLevelAlums)
            complete?(regularItem,topLevelItem)
            
        } deniedHander: { (status) in
            authorizationHandler?(status)
            complete?(RITLPhotosAlbumItem(),RITLPhotosAlbumItem())
        }
    }
    
    
    /// 进行权限检查
    static func authorizationCheck(allowHandler: RITLPhotosAuthorizationHandler? = nil, deniedHander: RITLPhotosAuthorizationHandler? = nil) {
        
        /// 进行回调处理
        func callback(status: PHAuthorizationStatus) {
            switch status {
            case .authorized: allowHandler?(status)
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization { (currentStatus) in
                    DispatchQueue.main.async {
                        callback(status: currentStatus)
                    }
                }
            case .denied: fallthrough
            case .restricted: deniedHander?(status)
            case .limited: allowHandler?(status)
            @unknown default: deniedHander?(status)
            }
        }
        
        /// 默认为未知
        var authorizationStatus: PHAuthorizationStatus = .notDetermined
        
        if #available(iOS 14, *) {
            authorizationStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        } else {
            authorizationStatus = PHPhotoLibrary.authorizationStatus()
        }
        
        callback(status: authorizationStatus)
    }
}



class RITLFetchResultTransformer {
    
    /// 转成数组
    static func toArray<T>(result: PHFetchResult<T>) -> [T] {
        var results = [T]()
        result.enumerateObjects { (obj, _, _) in
            results.append(obj)
        }
        return results
    }
}


fileprivate extension Array where Element: PHAssetCollection {
    
    /// 进行默认排序
    /// 如果存在最近添加，将最近添加放在第一位
    /// 如果存在相册组，将其放在其次
    func ritl_p_defalutSort() -> [Element] {
        // 排除相册中没有相片的选项
        var sortCollections = self.filter{ PHAsset.fetchAssets(in: $0, options: nil).count > 0 }
        
        //获得默认的最近添加library
        let recentAddLibrary = (self.filter{ $0.assetCollectionSubtype == .smartAlbumRecentlyAdded }).first
        //获得默认的最近添加索引
        if let recentAddLibrary = recentAddLibrary, let index = sortCollections.firstIndex(of: recentAddLibrary) {
            //移除即可
            sortCollections.remove(at: index)
        }
        
        //获得默认的相册组
        let userLibaray = (self.filter{ $0.assetCollectionSubtype == .smartAlbumUserLibrary }).first
        //获得默认的相册组
        if let userLibrary = userLibaray, let index = sortCollections.firstIndex(of: userLibrary) {
            //移除即可
            sortCollections.remove(at: index)
        }
         
        let result = (recentAddLibrary != nil ? [recentAddLibrary!] : []) + (userLibaray != nil ? [userLibaray!] : []) + sortCollections
        
        //返回符合条件的数据
        return result.filter{ $0.estimatedAssetCount != 0 }
    }
}


typealias RITLPHAssetCollectionToImageHandler = (_ collection: PHAssetCollection, _ title: String?, _ count: Int, _ image: UIImage?, _ requestID: PHImageRequestID?)->()
extension PHAssetCollection {
    
    /// 获得PHAssetCollection对象的标题、张数、缩略图
    /// - Parameters:
    ///   - size: 缩略图大小
    ///   - mode: PHImageRequestOptionsDeliveryMode
    ///   - requestID: 上次请求返回的ID
    ///   - complete: 完成后的回调
    func ritl_p_image(size: CGSize, mode: PHImageRequestOptionsDeliveryMode, requestID: PHImageRequestID? = nil, complete: RITLPHAssetCollectionToImageHandler?) {
        // 回调不存在，不需要进行任何操作
        guard let complete = complete else { return }
        let cachingImageManager = PHCachingImageManager.default()
        // 如果存在ID
        if let requestID = requestID {
            cachingImageManager.cancelImageRequest(requestID)
        }
        //获得图片资源
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        let result = PHAsset.fetchAssets(in: self, options: options)
        guard result.count > 0 else {
            complete(self, localizedTitle, 0, nil, nil); return
        }
        //根据屏幕进行点的计算
        let scale = UIScreen.main.scale
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        //options
        let requestOptions = PHImageRequestOptions()
        requestOptions.deliveryMode = mode
        //开始获取图片
        guard let asset = result.lastObject else {
            complete(self, localizedTitle, result.count, nil, nil); return
        }
        cachingImageManager.requestImage(for: asset, targetSize: newSize, contentMode: .aspectFill, options: requestOptions) { (image, info) in
            
            complete(self, self.localizedTitle, result.count, image, nil)
        }
    }
}


extension PHAsset {
    
    /// 根据identifiers顺序返回并转成数组
    /// 默认系统方法不会按照identifiers顺序返回result
    class func ritl_photo_fetchAssets(withLocalIdentifiers identifiers: [String], options: PHFetchOptions?) -> [PHAsset] {
        //返回即可
        return (identifiers.reduce([PHAsset?]()) { result, identifier in
            return result + [PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: nil).firstObject]
        }).compactMap { $0 }
    }
}
