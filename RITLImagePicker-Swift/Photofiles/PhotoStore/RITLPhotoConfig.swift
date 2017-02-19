//
//  RITLPhotoConfig.swift
//  RITLImagePicker-Swift
//
//  Created by YueWen on 2017/1/9.
//  Copyright © 2017年 YueWen. All rights reserved.
//

import UIKit


class RITLPhotoConfig: NSObject
{
    
    /// 配置选项，默认为如下
    static var groupNames : [String] = [
    
        NSLocalizedString(ConfigurationCameraRoll, comment: ""),
        NSLocalizedString(ConfigurationAllPhotos, comment: ""),
        NSLocalizedString(ConfigurationSlo_mo, comment: ""),
        NSLocalizedString(ConfigurationScreenshots, comment: ""),
        NSLocalizedString(ConfigurationVideos, comment: ""),
        NSLocalizedString(ConfigurationPanoramas, comment: ""),
        NSLocalizedString(ConfigurationRecentlyAdded, comment: ""),
        NSLocalizedString(ConfigurationSelfies, comment: ""),
        
    ]
    
//    /// 默认不需要展示的选项
//    static var ignoreGroupNames : [String] = [
//    
//        NSLocalizedString(ConfigurationHidden, comment: ""),
//        NSLocalizedString(ConfigurationTime_lapse, comment: ""),
//        NSLocalizedString(ConfigurationRecentlyDeleted, comment: ""),
//        NSLocalizedString(ConfigurationBursts, comment: ""),
//        NSLocalizedString(ConfigurationFavorite, comment: ""),
//    
//    ]
//    
    
    /// 获得的配置选项
    var groups : [String]{
        
        get{
            return RITLPhotoConfig.groupNames
        }
        
    }
    
    
    override init()
    {
        super.init()
    }
    
    
    convenience init(groupnames:[String]!)
    {
        self.init()
        
        RITLPhotoConfig.groupNames = groupnames
        //本地化
        localizeHandle()

    }
    
    
    
    /// 本地化语言处理
    func localizeHandle()
    {
        let localizedHandle = RITLPhotoConfig.groupNames
        
        let finalHandle = localizedHandle.map { (configurationName) -> String in
            
            return NSLocalizedString(configurationName, comment: "")
            
        }
        
        RITLPhotoConfig.groupNames = finalHandle
        
    }
    
}
