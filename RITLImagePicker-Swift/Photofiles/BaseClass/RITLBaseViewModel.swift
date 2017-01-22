//
//  RITLBaseViewModel.swift
//  RITLImagePicker-Swift
//
//  Created by YueWen on 2017/1/9.
//  Copyright © 2017年 YueWen. All rights reserved.
//

import UIKit

typealias RITLShouldDismissClosure = ((Void)->Void)
typealias RITLShouldAlertToWarningClosure = ((Bool,UInt) -> Void)

/// 基础的viewModel
class RITLBaseViewModel: NSObject
{
    /// 选择图片达到最大上线，需要提示
    var warningClosure : RITLShouldAlertToWarningClosure?
    
    /// 模态弹出
    var dismissClosure : RITLShouldDismissClosure?
    
    /// 选择图片完成
    func photoDidSelectedComplete()
    {
        dismissClosure?()
    }
}
