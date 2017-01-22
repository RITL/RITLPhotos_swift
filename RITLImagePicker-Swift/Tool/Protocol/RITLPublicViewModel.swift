//
//  RITLPublicViewModel.swift
//  RITLImagePicker-Swift
//
//  Created by YueWen on 2017/1/9.
//  Copyright © 2017年 YueWen. All rights reserved.
//

import Foundation


@objc protocol RITLPublicViewModel : NSObjectProtocol
{
    /// 当前控制器的导航标题
    @objc optional var title : String { get }
}
