//
//  RITLPhotosCell.swift
//  RITLImagePicker-Swift
//
//  Created by YueWen on 2017/1/16.
//  Copyright © 2017年 YueWen. All rights reserved.
//

import UIKit

typealias RITLPhotoCellOperationClosure = ((RITLPhotosCell) -> Void)

let ritl_deselectedImage = UIImage(named: "RITLDeselected")
let ritl_selectedImage  = UIImage(named: "RITLSelected")

/// 选择图片的cell
class RITLPhotosCell: UICollectionViewCell
{
    
    /// control对象点击的闭包
    var chooseImageDidSelectHandle :RITLPhotoCellOperationClosure?
    
    
    /// 显示图片的背景图片
    lazy var ritl_imageView : UIImageView = {
    
        var imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .white
    
        return imageView
    
    }()
    
    
    /// 显示信息的视图，比如视频的时间长度，默认hidden = true
    lazy var ritl_messageView : UIView = {
        
        let view = UIView()
        
        view.isHidden = true
        view.backgroundColor = .black
        
        return view
        
    }()
    
    
    /// 显示在ritl_messageView上显示时间长度的标签
    lazy var ritl_messageLabel : UILabel = {
       
        var messageLabel = UILabel()
        messageLabel.font = .systemFont(ofSize: 11)
        messageLabel.textColor = .white
        messageLabel.textAlignment = .right
        messageLabel.text = "00:25"
        
        return messageLabel
        
    }()
    
    
    /// 模拟显示选中的按钮
    lazy var ritl_chooseImageView : UIImageView = {
       
        var chooseImageView = UIImageView()
        chooseImageView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        chooseImageView.layer.cornerRadius = 25 / 2.0
        chooseImageView.clipsToBounds = true
        chooseImageView.image = ritl_deselectedImage
        
        return chooseImageView
        
    }()
    

    /// 模拟响应选中状态的control对象
    lazy var ritl_chooseControl : UIControl = {
        
        var chooseControl = UIControl()
        chooseControl.backgroundColor = .clear
        
        chooseControl.action(at: .touchUpInside, handle: { [weak self](sender) in
            
            let strongSelf = self
            
            //响应选择回调
            strongSelf!.chooseImageDidSelectHandle?(strongSelf!)
            
        })
        
        return chooseControl
        
    }()
    
    
    override init(frame: CGRect){
        
        super.init(frame: frame)
        addAndLayoutSubViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }
    
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        addAndLayoutSubViews()
    }
    
    
    
    /// cell进行点击
    ///
    /// - Parameter isSelected: 当前选中的状态
    func selected(_ isSelected:Bool)
    {
        ritl_chooseImageView.image = !isSelected ? ritl_deselectedImage : ritl_selectedImage
        
        if isSelected {
            
           animatedForSelected()
        }
    }
    
    
    // MARK: private
    
    /// 选中动画
    fileprivate func animatedForSelected()
    {
        UIView.animate(withDuration: 0.2, animations: { 
            
            self.ritl_chooseImageView.transform = CGAffineTransform(scaleX: 1.2,y: 1.2)
            
        }) { (finish) in
            
            UIView.animate(withDuration: 0.2, animations: { 
                
              self.ritl_chooseImageView.transform = CGAffineTransform.identity
                
            })
        }
    }
    
    
    
    override func prepareForReuse() {
        
        ritl_imageView.image = nil
        ritl_chooseImageView.isHidden = false
        ritl_messageView.isHidden = true
        ritl_messageLabel.text = nil
        ritl_chooseImageView.image = ritl_deselectedImage
    }
    
    
    fileprivate func addAndLayoutSubViews(){
     
        // subviews
        self.contentView.addSubview(ritl_imageView)
        self.contentView.addSubview(ritl_messageView)
        self.contentView.addSubview(ritl_chooseControl)
        ritl_chooseControl.addSubview(ritl_chooseImageView)
        ritl_messageView.addSubview(ritl_messageLabel)

        //layout
        ritl_imageView.snp.makeConstraints { (make) in
            
            make.edges.equalToSuperview()
            
        }
        
        ritl_chooseControl.snp.makeConstraints { (make) in
            
            make.width.height.equalTo(45)
            make.right.bottom.equalToSuperview().inset(3)
            
        }
        
        ritl_chooseImageView.snp.makeConstraints { (make) in
            
            make.width.height.equalTo(25)
            make.right.bottom.equalToSuperview()
            
        }
        
        
        ritl_messageView.snp.makeConstraints {(make) in
            
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(20)
            
        }
        
        ritl_messageLabel.snp.makeConstraints { [weak self](make) in
            
            let strongSelf = self
            
            make.left.equalTo(strongSelf!.ritl_messageView.snp.left)
            make.right.equalTo(strongSelf!.ritl_messageView).inset(3)
            make.bottom.equalTo(strongSelf!.ritl_messageView)
            make.height.equalTo(20)
        }
    }
    
}

