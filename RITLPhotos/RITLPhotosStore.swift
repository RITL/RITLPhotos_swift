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
    ///   - complete: 获得分组完成，如果权限无法获取，则不进行该回调
    ///   - authorizationDeniedHandler: 权限回调
    func fetchAlbumGroups(autoSort: Bool = false,
                          needTopLevel: Bool = false ,
                          complete: ((_ regular: RITLPhotosAlbumItem<PHFetchResult<PHAssetCollection>,PHAssetCollection>,
                                      _ topLeve: RITLPhotosAlbumItem<PHFetchResult<PHCollection>,PHCollection>?)->())? = nil,
                          authorizationHandler: RITLPhotosAuthorizationHandler? = nil) {
        
        //权限检测
        PHPhotoLibrary.authorizationCheck { (status) in
            //进行权限回调
            authorizationHandler?(status)
            //获得regular的数据
            let smartAlum = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
            //进行数据转换
            var smartAlums = RITLFetchResultTransformer.toArray(result: smartAlum)
            //如果需要排序，进行排序
            if (autoSort) {
                smartAlums = smartAlums.defalutSort()
            }
            //生成regularItem
            let regularItem = RITLPhotosAlbumItem(data: smartAlum, datas: smartAlums)
            //如果不需要直接返回即可
            guard needTopLevel else {
                complete?(regularItem, nil); return
            }
            
            //获得自定义相册组
            let topLevelAlum = PHCollection.fetchTopLevelUserCollections(with: nil)
            let topLevelAlums = RITLFetchResultTransformer.toArray(result: topLevelAlum)
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



fileprivate class RITLFetchResultTransformer {
    
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
    func defalutSort() -> [Element] {
        //
        var sortCollections = self
        //获得默认的library
        guard let userLibrary = (self.filter{ $0.assetCollectionSubtype == .smartAlbumUserLibrary }).first else {
            return self
        }
        //获得index
        guard let index = sortCollections.firstIndex(of: userLibrary) else {
            return self
        }
        //进行删除以及替换
        sortCollections.remove(at: index)
        sortCollections.insert(userLibrary, at: 0)
        return sortCollections
    }
}
