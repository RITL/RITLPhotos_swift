//
//  RITLPhotosCollectionTableViewCell.swift
//  RITLImagePicker-Swift
//
//  Created by YueWen on 2021/4/16.
//  Copyright © 2021 YueWen. All rights reserved.
//

import UIKit

public class RITLPhotosRowTableViewCell: UITableViewCell {

    /// 相册组的id
    var collectionId = ""
    /// 图片
    let iconImageView = UIImageView()
    /// 组的名称
    let titleLabel = UILabel()
    /// 组的数量
    let countLabel = UILabel()
    /// 是否选择的当前
    let selectedImageView = UIImageView()
    
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = 47.ritl_p_color
        
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(countLabel)
        contentView.addSubview(selectedImageView)
        
//        iconImageView.backgroundColor = .systemOrange
        iconImageView.contentMode = .scaleAspectFill
        
        titleLabel.text = "最近项目"
        titleLabel.textColor = .white
        titleLabel.font = RITLPhotoFont.regular.font(size: 15)
        
        countLabel.text = "(1395)"
        countLabel.textColor = 113.ritl_p_color
        countLabel.font = RITLPhotoFont.regular.font(size: 14)
        
        selectedImageView.image = RITLPhotosImage.group_select.image
        
        let separatorView = UIView()
        separatorView.backgroundColor = 70.ritl_p_color
        contentView.addSubview(separatorView)
        
        iconImageView.snp.makeConstraints { (make) in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalTo(iconImageView.snp.height)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(iconImageView.snp.trailing).offset(10)
            make.centerY.equalToSuperview().offset(-0.25)
            make.height.equalTo(21)
        }
        
        countLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(titleLabel.snp.trailing).offset(5)
            make.centerY.equalTo(titleLabel)
        }
        
        selectedImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(titleLabel)
            make.width.height.equalTo(15)
            make.trailing.equalToSuperview().inset(15)
        }
        
        separatorView.snp.makeConstraints { (make) in
            make.bottom.trailing.equalToSuperview()
            make.height.equalTo(0.5)
            make.leading.equalTo(iconImageView.snp.trailing)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("\(type(of: self)) is deinit")
    }
    
}
