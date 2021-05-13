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
        iconImageView.clipsToBounds = true
        
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
        
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        iconImageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        iconImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        iconImageView.widthAnchor.constraint(equalTo: iconImageView.heightAnchor).isActive = true
        
//        iconImageView.snp.makeConstraints { (make) in
//            make.leading.top.bottom.equalToSuperview()
//            make.width.equalTo(iconImageView.snp.height)
//        }
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 10).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -0.25).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 21).isActive = true
        
//        titleLabel.snp.makeConstraints { (make) in
//            make.leading.equalTo(iconImageView.snp.trailing).offset(10)
//            make.centerY.equalToSuperview().offset(-0.25)
//            make.height.equalTo(21)
//        }
        
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        countLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 5).isActive = true
        countLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor).isActive = true
        
//        countLabel.snp.makeConstraints { (make) in
//            make.leading.equalTo(titleLabel.snp.trailing).offset(5)
//            make.centerY.equalTo(titleLabel)
//        }
        
        selectedImageView.translatesAutoresizingMaskIntoConstraints = false
        selectedImageView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor).isActive = true
        selectedImageView.widthAnchor.constraint(equalToConstant: 15).isActive = true
        selectedImageView.heightAnchor.constraint(equalToConstant: 15).isActive = true
        selectedImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15).isActive = true
        
//        selectedImageView.snp.makeConstraints { (make) in
//            make.centerY.equalTo(titleLabel)
//            make.width.height.equalTo(15)
//            make.trailing.equalToSuperview().inset(15)
//        }
        
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        separatorView.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        separatorView.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor).isActive = true
        
//        separatorView.snp.makeConstraints { (make) in
//            make.bottom.trailing.equalToSuperview()
//            make.height.equalTo(0.5)
//            make.leading.equalTo(iconImageView.snp.trailing)
//        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        ritl_p_print("\(type(of: self)) is deinit")
    }
    
}
