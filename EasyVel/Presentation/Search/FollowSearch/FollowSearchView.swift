//
//  SubscriberSearchView.swift
//  VelogOnMobile
//
//  Created by 홍준혁 on 2023/04/29.
//

import UIKit

import SnapKit

final class FollowSearchView: BaseUIView {
    
    //MARK: - UI Components
        
    let userContentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.makeRounded(radius: 16)
        view.isHidden = true
        return view
    }()
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .headline
        label.textColor = .gray700
        label.textAlignment = .center
        return label
    }()
    
    let introduceLabel: UILabel = {
        let label = UILabel()
        label.font = .body_1_M
        label.textColor = .gray500
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    
    let followButton: UIButton = {
        let button = UIButton()
        button.setTitle("팔로우 취소", for: .selected)
        button.setTitle("팔로우", for: .normal)
        button.titleLabel?.font = .body_2_B
        button.backgroundColor = .brandColor
        return button
    }()
    
    let notFoundImageView: UIImageView = {
        let imageView = UIImageView(image: ImageLiterals.notFoundUser)
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        return imageView
    }()
    
    
    //MARK: - Life Cycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.makeRounded(ratio: 2)
        followButton.makeRounded(ratio: 2)
    }
    
    //MARK: - Custom Method
    
    
    override func configUI() {
        self.backgroundColor = .gray100
        
        addSubviews(userContentView, notFoundImageView)
        
        userContentView.addSubviews(imageView,
                                nameLabel,
                                introduceLabel,
                                followButton)
        
        notFoundImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.height.equalTo(200)
            $0.horizontalEdges.equalToSuperview().inset(110)
        }
        
        userContentView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(144)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
        
        imageView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(32)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(118)
        }
        
        nameLabel.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
        }
        
        introduceLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(4)
            $0.centerX.equalToSuperview()
        }
        
        followButton.snp.makeConstraints {
            $0.top.equalTo(introduceLabel.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(110)
            $0.height.equalTo(46)
            $0.bottom.equalToSuperview().inset(32)
        }
    }
    
}
