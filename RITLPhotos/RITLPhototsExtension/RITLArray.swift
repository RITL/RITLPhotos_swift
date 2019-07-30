//
//  RITLArray.swift
//  RITLImagePicker-Swift
//
//  Created by YueWen on 2019/7/30.
//  Copyright © 2019 YueWen. All rights reserved.
//

import Foundation
import Photos

extension Array where Element: PHAssetCollection {
    
    /// 将用户相册排到第一位
    func sortedToUserLibraryFirst() -> [Element]{
        return sorted(by: { (first, _) -> Bool in
            return first.assetCollectionSubtype == .smartAlbumUserLibrary
        })
    }
}
