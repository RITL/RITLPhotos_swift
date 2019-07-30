//
//  RITLFetchResult.swift
//  RITLImagePicker-Swift
//
//  Created by YueWen on 2019/7/30.
//  Copyright © 2019 YueWen. All rights reserved.
//

import Foundation
import Photos


struct PHFetchResultHandler {
    
    /// 将 PHFetchResult 转成 Array
    static func transToArray<Element>(fetchResult: PHFetchResult<Element>) -> [Element]{
        
        var result = [Element]()
        fetchResult.enumerateObjects { (obj, idx, _) in
            result.append(obj)
        }
        return result
    }
    
}
