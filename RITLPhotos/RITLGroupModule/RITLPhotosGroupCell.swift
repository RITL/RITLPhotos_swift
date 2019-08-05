//
//  RITLPhotosGroupCell.swift
//  RITLImagePicker-Swift
//
//  Created by YueWen on 2019/7/30.
//  Copyright © 2019 YueWen. All rights reserved.
//

import UIKit

/// RITLPhotos - 展示分组的cell
final class RITLPhotosGroupCell: UITableViewCell {

    /// 展示图片的imageView
    let leadingImageView = UIImageView()
    /// 展示相册名称
    let titleLabel = UILabel()
    /// 右箭头
    let arrowImageView = UIImageView()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        buildViews()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        buildViews()
    }
    
    
    private func buildViews(){
        
        leadingImageView.contentMode = .scaleAspectFit
        leadingImageView.clipsToBounds = true
        
        titleLabel.font = RITLPhotosFont.medium.font(size: 15)
        
        arrowImageView.image = RITLPhotosImage.arrowRight.image()
        
        contentView.addSubview(leadingImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(arrowImageView)
        
        leadingImageView.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(10)
            make.width.equalTo(leadingImageView.snp.height)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.leading.equalTo(leadingImageView.snp.trailing).offset(10)
            make.right.equalToSuperview().inset(10)
        }
        
        arrowImageView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().inset(15)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(15)
        }
    }
}
