//
//  RITLPhotosGroupCell.swift
//  RITLImagePicker-Swift
//
//  Created by YueWen on 2019/7/30.
//  Copyright © 2019 YueWen. All rights reserved.
//

import UIKit

/// RITLPhotos - 展示分组的cell
public final class RITLPhotosGroupCell: UITableViewCell {

    /// 展示图片的imageView
    @IBOutlet weak var leadingImageView: UIImageView!
    /// 展示相册名称
    @IBOutlet weak var titleLabel: UILabel!
    /// 右箭头
    @IBOutlet weak var arrowImageView: UIImageView!
}
