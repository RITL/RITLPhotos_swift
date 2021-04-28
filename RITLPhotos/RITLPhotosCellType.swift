//
//  RITLPhotosCellType.swift
//  RITLImagePicker-Swift
//
//  Created by YueWen on 2021/4/27.
//  Copyright © 2021 YueWen. All rights reserved.
//

import Foundation
import Photos


public enum RITLPhotoDifferencesKey: String {
    case add
    case remove
}


enum RITLPhotosCollectionCellType: String, CaseIterable {
    case video
    case live
    case photo
    case unknown
}


extension PHAsset {
    
    /// 注册的样式
    func cellIdentifier() -> RITLPhotosCollectionCellType {
        //进行图片以及视频的区分
        switch mediaType {
        case .video: return .video
        case .image:
            if #available(iOS 9.1, *) {
                switch mediaSubtypes {
                case .photoLive: return .live
                default: return .photo
                }
            } else {
                // Fallback on earlier versions
                return .photo
            }
        default: return .unknown
        }
    }
    
}
