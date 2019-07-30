//
//  RITLPhotoLibrary.swift
//  RITLImagePicker-Swift
//
//  Created by YueWen on 2019/7/30.
//  Copyright © 2019 YueWen. All rights reserved.
//

import Foundation
import Photos

extension PHPhotoLibrary {
    
    
    /// 使用图片Library的权限检测
    ///
    /// - Parameters:
    ///   - allow: 可以使用权限
    ///   - denied: 权限禁止使用
    static func checkAuthorizationStatus(allow: (()->())?, denied:(() -> ())? = nil){
        
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized: allow?() //允许使用
        case .notDetermined: //进行权限请求
            PHPhotoLibrary.requestAuthorization { (status) in
                DispatchQueue.main.async {
                    switch status {
                    case .authorized: allow?() //允许使用
                    default: denied?() //禁止使用
                    }
                }
            }
        case .denied: fallthrough
        case .restricted: denied?()
        @unknown default: print("Unknown authorizationStatus")
        }
    }
    

    /// 获得只能分类的相册和自定义的相册
    ///
    /// - Parameters:
    ///   - complete: 获取成功
    ///   - fail: 获取失败
    func fetchAblumRegularAndTopLevelUserResults(complete:@escaping ((PHFetchResult<PHAssetCollection>,PHFetchResult<PHCollection>) ->()),
                                                 fail: ((String)->())?) {
        
        PHPhotoLibrary.checkAuthorizationStatus(allow: {
            
            //获得智能分组
            let smartAlbum = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
            //获得个人相册
            let topLevelUser = PHAssetCollection.fetchTopLevelUserCollections(with: nil)
            //返回
            complete(smartAlbum, topLevelUser)
            
        }) {
            fail?("获取相册权限失败")
        }
    }
    
}
