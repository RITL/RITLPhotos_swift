//
//  RITLPhotoGroupCell.swift
//  RITLImagePicker-Swift
//
//  Created by YueWen on 2017/1/10.
//  Copyright © 2017年 YueWen. All rights reserved.
//

import UIKit

/// 组的自定义cell
class RITLPhotoGroupCell: UITableViewCell {

    
    /// 显示图片的imageview
    var ritl_imageView : UIImageView?
    
    /// 分组名称
    var ritl_titleLabel : UILabel?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        photoGroupCellWillLoad()
        
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        photoGroupCellWillLoad()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    override func prepareForReuse() {
    
        super.prepareForReuse()
        
        self.ritl_imageView?.image = nil
        self.ritl_titleLabel?.text = ""
    }
    
    
    fileprivate func photoGroupCellWillLoad()
    {
        addRitl_imageView()
        addRitl_titleLable()
    }
    
    
    
    func addRitl_imageView()
    {
        ritl_imageView = UIImageView()
        ritl_imageView?.contentMode = .scaleAspectFill
        ritl_imageView?.clipsToBounds = true
        
        contentView.addSubview(ritl_imageView!)
        
        ritl_imageView?.snp.makeConstraints({ (make) in
            
            make.top.equalToSuperview().inset(5)
            make.bottom.equalToSuperview().inset(5)
            make.leading.equalToSuperview().inset(10)
            make.width.equalTo((ritl_imageView?.snp.height)!)
        })
    }
    
    
    func addRitl_titleLable()
    {
        ritl_titleLabel = UILabel()
        ritl_titleLabel?.font = .systemFont(ofSize: 15)
        
        contentView.addSubview(ritl_titleLabel!)
        
        ritl_titleLabel?.snp.makeConstraints({ (make) in
            
            make.centerY.equalTo(contentView.snp.centerY)
            make.left.equalTo((ritl_imageView?.snp.right)!).offset(10)
            make.right.equalToSuperview().inset(10)
            
        })
    }

}
