//
//  RITLPhotosCollectionViewCell.swift
//  RITLImagePicker-Swift
//
//  Created by YueWen on 2021/4/20.
//  Copyright © 2021 YueWen. All rights reserved.
//

import UIKit
import Photos

/// 基类
public class RITLPhotosCollectionViewCell: UICollectionViewCell {
    /// 用于标记图片的id
    var assetIdentifer = ""
    /// 显示图片的imageView
    let iconImageView = UIImageView()
    /// 显示索引号的label
    let indexLabel = UILabel()
    /// 选择的按钮
    let chooseButton = UIButton()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        addSubViews()
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        addSubViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 追加自己的subViews
    public func addSubViews() {
        backgroundColor = 50.ritl_p_color
        contentView.backgroundColor = 50.ritl_p_color
        
        iconImageView.clipsToBounds = true
        iconImageView.contentMode = .scaleAspectFill
        
        chooseButton.imageView?.layer.cornerRadius = 21 / 2.0
        chooseButton.imageView?.backgroundColor = 227.ritl_p_color.withAlphaComponent(0.3)
        chooseButton.imageEdgeInsets = UIEdgeInsets(top: 5, left: 9, bottom: 14, right: 10)
        chooseButton.imageView?.clipsToBounds = true
        chooseButton.setTitle("1", for: .selected)
        chooseButton.setTitleColor(.white, for: .selected)
        chooseButton.setImage(RITLPhotosImage.collection_normal.image, for: .normal)
        
        contentView.addSubview(iconImageView)
        contentView.addSubview(chooseButton)
        
        iconImageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        chooseButton.snp.makeConstraints { (make) in
            make.width.height.equalTo(40)
            make.top.trailing.equalToSuperview()
        }
        
//        indexLabel.backgroundColor =
        //未选中的图片
        
    }
}



/// 正常的显示单一图片的cell
public class RITLPhotosNormalCollectionCell: RITLPhotosCollectionViewCell {

    
}


/// 显示Live照片
public class RITLPhotosLiveCollectionCell: RITLPhotosCollectionViewCell {
    /// 支持支持iOS9.1之后的livePhoto
    let liveBadgeImageView = UIImageView()
}


/// 显示Video
public class RITLPhotosVideoCollectionCell: RITLPhotosCollectionViewCell {

    /// 展示视频出现的信息搭载视图，默认为隐藏
    private let messageView = UIView()
    
    /// 显示视频信息
    let messageImageView = UIImageView()
    let messageLabel = UILabel()
}
