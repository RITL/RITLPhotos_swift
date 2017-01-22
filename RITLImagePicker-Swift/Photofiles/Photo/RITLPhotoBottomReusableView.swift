//
//  RITLPhotoBottomReusableView.swift
//  RITLImagePicker-Swift
//
//  Created by YueWen on 2017/1/16.
//  Copyright © 2017年 YueWen. All rights reserved.
//

import UIKit


class RITLPhotoBottomReusableView: UICollectionReusableView
{
    /// 资源的数目
    var ritl_numberOfAsset = 0 {
        
        willSet{
           
            self.ritl_assetLabel.text = "共有\(newValue)张照片"
            
        }
    }
    
    /// 在标签上的自定义文字
    var ritl_customText = "" {
       
        willSet{
            
            self.ritl_assetLabel.text = newValue
        }
        
    }
    
    /// 显示title的标签
    var ritl_assetLabel : UILabel = {
       
        var assetLabel = UILabel()
        
        assetLabel.font = .systemFont(ofSize: 14)
        assetLabel.textAlignment = .center
        assetLabel.textColor = .colorValue(with: 0x6F7179)
        
        return assetLabel
        
    }()
    
    
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        layoutOwnSubviews()
    }
    
    
    
     required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }
    
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        layoutOwnSubviews()
    }
    
    
    override func prepareForReuse() {
        
        super.prepareForReuse()
        
        ritl_customText = ""
    }
    
    
    // MARK: private
    
    fileprivate func layoutOwnSubviews()
    {
        self.addSubview(ritl_assetLabel)
        
        //layout
        ritl_assetLabel.snp.makeConstraints { (make) in
            
            make.edges.equalToSuperview()
        }
    }
}
