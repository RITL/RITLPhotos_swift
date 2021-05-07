//
//  RITLPhotosConfigation.swift
//  RITLImagePicker-Swift
//
//  Created by YueWen on 2021/4/26.
//  Copyright © 2021 YueWen. All rights reserved.
//

import UIKit


public class RITLPhotosConfigation: NSObject {

    /// 局部单例
    private static weak var instance: RITLPhotosConfigation?
    
    /// 最大选择数
    var maxCount = 9
    /// 是否支持视频
    /// 如果为false，视频选项将不能被选择，但是可以浏览
    var isSupportVideo = true
    
    private override init() {
        super.init()
    }
    
    /// 局部单例
    static func `default`() -> RITLPhotosConfigation {
        var strongInstance = instance
        objc_sync_enter(self)
        if strongInstance == nil {
            strongInstance = RITLPhotosConfigation()
            instance = strongInstance
        }
        objc_sync_exit(self)
        return strongInstance!
    }
    
    deinit {
        ritl_p_print("\(type(of: self)) is deinit")
    }
}
