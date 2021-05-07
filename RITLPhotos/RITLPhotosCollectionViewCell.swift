//
//  RITLPhotosCollectionViewCell.swift
//  RITLImagePicker-Swift
//
//  Created by YueWen on 2021/4/20.
//  Copyright © 2021 YueWen. All rights reserved.
//

import UIKit
import Photos
import PhotosUI

public enum RITLPhotosCellAnimatedStatus: Int {
    /// 允许使用
    case permit
}

public typealias RITLPhotosCellStatusAction = (RITLPhotosCellAnimatedStatus, Bool, Int)->()

public protocol RITLPhotosCollectionCellActionTarget: AnyObject {
    
    /// 选中按钮被点击后的回调
    func photosCollectionCell(selectedDidTap cell: RITLPhotosCollectionViewCell, complete: RITLPhotosCellStatusAction?)
}

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
    /// 选中后的遮罩
    let shadowView = UIView()
    
    ///weak数据
    weak var delegate: RITLPhotosCollectionCellActionTarget?
    weak var asset: PHAsset?
    var indexPath: IndexPath?
    
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
        chooseButton.setTitle("", for: .selected)
        chooseButton.setTitleColor(.white, for: .selected)
        chooseButton.setImage(RITLPhotosImage.tool_bottom_deselect.image, for: .normal)
        chooseButton.addTarget(self, action: #selector(chooseButtonDidTap), for: .touchUpInside)
        
        indexLabel.text = "0"
        indexLabel.backgroundColor = #colorLiteral(red: 0.03529411765, green: 0.7333333333, blue: 0.3529411765, alpha: 1)
        indexLabel.textColor = .white
        indexLabel.font = RITLPhotoFont.regular.font(size: 13)
        indexLabel.textAlignment = .center
        indexLabel.clipsToBounds = true
        indexLabel.layer.cornerRadius = 21 / 2.0
        indexLabel.isHidden = true
        
        
        shadowView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        shadowView.isHidden = true
        
        contentView.addSubview(iconImageView)
        contentView.addSubview(shadowView)
        contentView.addSubview(chooseButton)
        contentView.addSubview(indexLabel)
        
        iconImageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        shadowView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        chooseButton.snp.makeConstraints { (make) in
            make.width.height.equalTo(40)
            make.top.trailing.equalToSuperview()
        }
        
        indexLabel.snp.makeConstraints { (make) in
            make.width.height.equalTo(21)
            make.trailing.equalToSuperview().inset(10)
            make.top.equalToSuperview().offset(5)
        }
    }
    
    /// 选择按钮被点击
    @objc func chooseButtonDidTap() {
        //执行回调即可
        delegate?.photosCollectionCell(selectedDidTap: self, complete: { (status, isSelected, index) in
            switch status {
            case .permit: self.changedSelectedStatus(isSelected: isSelected, index: "\(index)")
            }
        })
    }
    
    private func changedSelectedStatus(isSelected: Bool, index: String) {
        indexLabel.isHidden = !isSelected
        //未选中，清空即可
        guard isSelected else {
            self.indexLabel.text = ""; return
        }
        //选中的
        indexLabel.text = index
        //执行动画
        UIView.animate(withDuration: 0.15) {
            //放大
            self.indexLabel.transform = self.indexLabel.transform.scaledBy(x: 1.3, y: 1.3)
            
        } completion: { (_) in
            //缩小
            UIView.animate(withDuration: 0.1) {
                self.indexLabel.transform = .identity
            }
        }
    }
}



/// 正常的显示单一图片的cell
public class RITLPhotosNormalCollectionCell: RITLPhotosCollectionViewCell {

    
}


/// 显示Live照片
public class RITLPhotosLiveCollectionCell: RITLPhotosCollectionViewCell {
    /// 支持支持iOS9.1之后的livePhoto
    let liveBadgeImageView = UIImageView()
    
    public override func addSubViews() {
        super.addSubViews()
        
        liveBadgeImageView.backgroundColor = .clear
        liveBadgeImageView.contentMode = .scaleAspectFill
        if #available(iOS 9.1, *) {
            liveBadgeImageView.image = PHLivePhotoView.livePhotoBadgeImage(options: .overContent)
        }
        
        contentView.addSubview(liveBadgeImageView)
        liveBadgeImageView.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().inset(3)
            make.left.equalToSuperview().offset(3)
            make.width.height.equalTo(28)
        }
    }
}


/// 显示Video
public class RITLPhotosVideoCollectionCell: RITLPhotosCollectionViewCell {

    /// 展示视频出现的信息搭载视图，默认为隐藏
    private let messageView = UIView()
    
    /// 显示视频信息
    let messageImageView = UIImageView()
    let messageLabel = UILabel()
    
    public override func addSubViews() {
        super.addSubViews()
        
        messageView.backgroundColor = UIColor.black.withAlphaComponent(0.03)
        messageLabel.font = RITLPhotoFont.regular.font(size: 11)
        messageLabel.textAlignment = .right
        messageLabel.textColor = .white
        messageLabel.text = "00:25"
        
//        messageImageView.image = RITLPhotosImage.collection_video_icon.image
        
        contentView.addSubview(messageView)
        messageView.addSubview(messageImageView)
        messageView.addSubview(messageLabel)
        
        messageView.snp.makeConstraints { (make) in
            make.leading.bottom.trailing.equalToSuperview()
            make.height.equalTo(20)
        }
        
        messageImageView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(5)
//            make.bottom.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(20)
            make.width.equalTo(33)
        }
        
        messageLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(messageImageView.snp.trailing)
            make.trailing.equalToSuperview().inset(3)
            make.bottom.equalToSuperview()
            make.height.equalTo(20)
        }
    }
}
