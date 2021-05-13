//
//  RITLPhotosTopPickerView.swift
//  RITLImagePicker-Swift
//
//  Created by YueWen on 2021/4/15.
//  Copyright © 2021 YueWen. All rights reserved.
//

import UIKit

public protocol RITLPhotosNavigationItemViewDelegate: AnyObject {
    
    /// 选择图片的模块点击的回调
    func photosPickerViewDidTap(view: RITLPhotosNavigationItemView)
}

/// 导航栏顶部的选择栏
public class RITLPhotosNavigationItemView: UIView {
    
    ///
    weak var delegate: RITLPhotosNavigationItemViewDelegate? = nil
    
    /// 显示文本的标题
    let titleLabel = UILabel()
    /// 显示的图片
    let imageView = UIImageView()
    
    private var stackView: UIStackView?
    
    
    public convenience init(frame: CGRect, delegate: RITLPhotosNavigationItemViewDelegate?) {
        self.init(frame: frame)
        self.delegate = delegate
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    
        titleLabel.textAlignment = .right
        titleLabel.textColor = .white
        titleLabel.font = RITLPhotoFont.medium.font(size: 16)
        titleLabel.text = "最近项目"
        
        imageView.backgroundColor = 34.ritl_p_color
        imageView.layer.cornerRadius = 9
        imageView.image = RITLPhotosImage.pick_top_arrow.image
        
        let stackView = UIStackView()
        stackView.spacing = 5
        stackView.alignment = .center
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(imageView)
        stackView.isUserInteractionEnabled = false
        self.stackView = stackView
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.heightAnchor.constraint(equalToConstant: 18).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 18).isActive = true
        
//        imageView.snp.makeConstraints { (make) in
//            make.height.width.equalTo(18)
//        }

        
        let width: CGFloat = UIScreen.main.bounds.width - 80 - 15
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.heightAnchor.constraint(equalToConstant: 25).isActive = true
        titleLabel.widthAnchor.constraint(lessThanOrEqualToConstant: width).isActive = true
//        titleLabel.snp.makeConstraints { (make) in
//            make.height.equalTo(25)
//            make.width.lessThanOrEqualTo(width)
//        }
        
        let contentView = UIView()
        contentView.backgroundColor = #colorLiteral(red: 0.3058823529, green: 0.2980392157, blue: 0.3019607843, alpha: 1)
        contentView.layer.cornerRadius = 15
        contentView.isUserInteractionEnabled = false
        
        /// 响应点击的回调
        let control = UIControl()
        control.addTarget(self, action: #selector(pickerViewDidClick), for: .touchUpInside)
        
        addSubview(contentView)
        addSubview(control)
        addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.heightAnchor.constraint(equalToConstant: 25).isActive = true
        stackView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -9).isActive = true
        stackView.widthAnchor.constraint(lessThanOrEqualTo: self.widthAnchor).isActive = true
        
//        stackView.snp.makeConstraints { (make) in
//            make.height.equalTo(25)
//            make.centerX.equalToSuperview()
//            make.bottom.equalToSuperview().inset(9)
//            make.width.lessThanOrEqualTo(self)
//        }
        
//        stackView.backgroundColor = .systemYellow
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        contentView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: -10).isActive = true
        contentView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: 10).isActive = true
        contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -6.5).isActive = true
        
//        contentView.snp.makeConstraints { (make) in
//            make.height.equalTo(30)
//            make.leading.equalTo(stackView).offset(-10)
//            make.trailing.equalTo(stackView).offset(10)
//            make.bottom.equalToSuperview().inset(6.5)
//        }
        
        control.ritl_photos_anchorEdge(to: contentView)
//        
//        control.snp.makeConstraints { (make) in
//            make.edges.equalTo(contentView)
//        }
    }
    
    /// 修改显示的标题
    func updateTitle(text: String) {
        //如果个数一致，直接修改即可
        if titleLabel.text?.count == text.count {
            titleLabel.text = text
            return
        }
        //先移除再追加
        titleLabel.text = text
        stackView?.insertArrangedSubview(titleLabel, at: 0)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    @objc func pickerViewDidClick() {
        delegate?.photosPickerViewDidTap(view: self)
    }
    
    deinit {
        ritl_p_print("\(type(of: self)) is deinit")
    }
}
