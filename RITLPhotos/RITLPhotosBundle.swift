//
//  RITLPhotosBundle.swift
//  RITLImagePicker-Swift
//
//  Created by YueWen on 2021/4/14.
//  Copyright © 2021 YueWen. All rights reserved.
//

import UIKit

/// RITLPhotos 使用的图片
enum RITLPhotosImage: String {
    
    /// 导航栏关闭的按钮
    case nav_close = "ritl_photos_nav_close.png"
    
    /// 下方bar中原图按钮的选中
    case tool_bottom_selecte = "ritl_photos_bottom_selected.png"
    /// 下方bar中原图按钮的默认未选中
    case tool_bottom_deselect = "ritl_photos_bottom_deselected.png"
    
    /// 顶部导航的箭头按钮
    case pick_top_arrow = "ritl_photos_picker.png"
    
    /// 分组选中的标记
    case group_select =  "ritl_photos_group_select.png"
    
    /// 占位图
    case placeholder = "ritl_placeholder.png"
    /// 右侧的箭头
    case arrowRight = "ritl_arrow_right.png"
    
    //集合视图
    
    /// 集合视图
    case deselect = "ritl_deselect.png"
    
    //浏览视图
    
    /// 浏览右上角的选中
    case browerSelect = "ritl_brower_selected.png"
    /// 浏览左上角的返回
    case browseBack = "ritl_browse_back.png"

    /// 视频播放
    case videoPlayer = "ritl_video_play.png"
}


extension RITLPhotosImage {
    
    var image: UIImage? {
        //获得路径
        guard let path = RITLPhotosBundle.ritl_p_bundle()?.resourcePath else { return nil }
        //获得bundle
        return UIImage(contentsOfFile: "\(path)/\(self.rawValue)")
    }
}



class RITLPhotosBundle {
    /// 全局的bundle
    private static var _ritl_p_bundle: Bundle? = nil
    
    /// 获得bundle
    static func ritl_p_bundle() -> Bundle? {
        //返回实际即可
        if let bundle = _ritl_p_bundle {
            return bundle
        }
        //路径
        guard let path = Bundle(for: RITLPhotosViewController.self).path(forResource: "RITLPhotos", ofType: "bundle") else {
            return nil
        }
        _ritl_p_bundle = Bundle(path: path)
        return _ritl_p_bundle
    }
}

