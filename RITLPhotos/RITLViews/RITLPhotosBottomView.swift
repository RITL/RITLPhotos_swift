//
//  RITLPhotosBottomView.swift
//  RITLImagePicker-Swift
//
//  Created by YueWen on 2019/8/1.
//  Copyright © 2019 YueWen. All rights reserved.
//

import UIKit

final class RITLPhotosBottomView: UIView {

    private var contentView = UIView()
    /// 预览按钮
    var previewButton = UIButton()
    /// 原图按钮
    var fullButton = UIButton()
    /// 发送按钮
    var sendButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
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
        
        backgroundColor = UIColor.black.withAlphaComponent(0.8)
        contentView.backgroundColor = .clear
        
        previewButton.adjustsImageWhenHighlighted = false
        previewButton.backgroundColor = .clear
        previewButton.titleLabel?.font = RITLPhotosFont.regular.font(size: 15)
        previewButton.setTitle("预览", for: .normal)
        previewButton.setTitle("预览", for: .disabled)
        previewButton.setTitleColor(.white, for: .normal)
        previewButton.setTitleColor(#colorLiteral(red: 0.4117647059, green: 0.4274509804, blue: 0.4431372549, alpha: 1), for: .disabled)
        
        let leftMargin = (UIDevice.current.systemVersion as NSString).floatValue < 13 ? -60 : 5
        fullButton.imageEdgeInsets = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 40)
        fullButton.titleEdgeInsets.left = CGFloat(leftMargin)
        fullButton.titleLabel?.font = RITLPhotosFont.regular.font(size: 14)
        fullButton.setTitle("原图", for: .normal)
        fullButton.setTitle("原图", for: .selected)
        fullButton.setTitleColor(.white, for: .normal)
        fullButton.setImage(RITLPhotosImage.borwseBottomSelecte.image(), for: .selected)
        fullButton.setImage(RITLPhotosImage.borwseBottomDeselecte.image(), for: .normal)
        
        
        sendButton.adjustsImageWhenHighlighted = false
        sendButton.titleLabel?.font = RITLPhotosFont.regular.font(size: 13)
        sendButton.setTitle("发送", for: .normal)
        sendButton.setTitle("发送", for: .disabled)
        sendButton.setTitleColor(.white, for: .normal)
        sendButton.setTitleColor(#colorLiteral(red: 0.3607843137, green: 0.5254901961, blue: 0.3529411765, alpha: 1), for: .disabled)
        sendButton.layer.cornerRadius = 5
        sendButton.clipsToBounds = true
        sendButton.setBackgroundImage(#colorLiteral(red: 0.03529411765, green: 0.7333333333, blue: 0.02745098039, alpha: 1).ritlPhoto_image, for: .normal)
        sendButton.setBackgroundImage( #colorLiteral(red: 0.09019607843, green: 0.3254901961, blue: 0.09019607843, alpha: 1).ritlPhoto_image, for: .disabled)
        
        addSubview(contentView)
        contentView.addSubview(previewButton)
        contentView.addSubview(fullButton)
        contentView.addSubview(sendButton)
        
        contentView.snp.makeConstraints { (make) in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(RITLPhotosBarDistance.TabBar.height - 5)
        }
        
        previewButton.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.width.equalTo(40)
            make.left.equalToSuperview().offset(10)
        }
        
        fullButton.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.height.equalTo(30)
            make.width.equalTo(60)
        }
        
        sendButton.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(10)
            make.width.equalTo(65)
            make.height.equalTo(30)
        }
    }
}
