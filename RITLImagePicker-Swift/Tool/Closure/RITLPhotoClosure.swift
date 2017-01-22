//
//  RITLPhotoClosure.swift
//  RITLImagePicker-Swift
//
//  Created by YueWen on 2017/1/9.
//  Copyright © 2017年 YueWen. All rights reserved.
//

import Foundation
import UIKit

//
//typealias RITLPhotoDidSelectedClosure = (_:(([UIImage]) -> Swift.Void))
//typealias RITLPhotoDidSelectedBlockAsset = (_:([UIImage],[NSNumber]) -> Swift.Void)

typealias id = Any

typealias PhotoBlock = ((Void) -> Void)
typealias PhotoCompleteBlock0 = ((id) -> Void)
typealias PhotoCompleteBlock1 = ((id,id) -> Void)
typealias PhotoCompleteBlock2 = ((id,id,id,UInt) -> Void)
typealias PhotoCompleteBlock4 = ((id,id,Bool) -> Void)
typealias PhotoCompleteBlock5 = ((id,id,UInt) -> Void)
typealias PhotoCompleteBlock6 = ((Bool,UInt) -> Void)
typealias PhotoCompleteBlock7 = ((id,id,id,id,Int) -> Void)
typealias PhotoCompleteBlock8 = ((Bool,id) -> Void)
typealias PhotoCompleteBlock9 = ((Bool) -> Void)

