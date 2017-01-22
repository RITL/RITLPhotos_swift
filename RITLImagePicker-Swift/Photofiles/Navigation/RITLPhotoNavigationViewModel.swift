//
//  RITLPhotoNavigationViewModel.swift
//  RITLImagePicker-Swift
//
//  Created by YueWen on 2017/1/10.
//  Copyright © 2017年 YueWen. All rights reserved.
//

import UIKit

let RITLPhotoOriginSize:CGSize = CGSize(width: -100, height: -100)


/// 主导航控制器的viewModel
class RITLPhotoNavigationViewModel: RITLBaseViewModel {
    
    /// 最大的选择数量，默认为9
    var maxNumberOfSelectedPhoto = 9 {
        
        willSet {
            
            guard newValue > 0 else {
                
                return
            }
            
            RITLPhotoCacheManager.sharedInstance.maxNumeberOfSelectedPhoto = newValue
        }
    }
    
    
    /// 当前图片的规格，默认为RITLPhotoOriginSize，原始比例
    var imageSize = RITLPhotoOriginSize {
        
        willSet {
            
            RITLPhotoCacheManager.sharedInstance.imageSize = newValue
        }
    }
    
    
    /// 获取图片之后的闭包
    var completeUsingImage:(([UIImage]) -> Void)? {
        
        willSet {
            
            RITLPhotoBridgeManager.sharedInstance.completeUsingImage = newValue
        }
    }
    
    
    /// 获取图片数据之后的闭包
    var completeUsingData:(([Data]) -> Void)? {
        
        willSet {
            
            RITLPhotoBridgeManager.sharedInstance.completeUsingData = newValue
        }
    }
    
    deinit
    {
        print("\(self.self)deinit")
    }

}
