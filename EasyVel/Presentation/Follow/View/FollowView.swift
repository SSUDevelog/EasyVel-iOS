//
//  ListView.swift
//  VelogOnMobile
//
//  Created by 홍준혁 on 2023/05/01.
//

import UIKit

import SnapKit

final class FollowView: BaseUIView {
    let followTableView = FollowTableView(frame: .null, style: .plain)
    let postsHeadView = FollowHeadView()
    let followViewExceptionView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = ImageLiterals.emptyFollower
        imageView.isHidden = true
        return imageView
    }()
    
    override func configUI() {
        self.backgroundColor = .gray100
    }
    
    override func render() {
        self.addSubviews(
            followTableView,
            postsHeadView,
            followViewExceptionView
        )
        
        postsHeadView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(196)
        }
        self.bringSubviewToFront(postsHeadView)
        
        followTableView.snp.makeConstraints {
            $0.top.equalTo(postsHeadView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        followViewExceptionView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(360)
            $0.height.equalTo(168)
            $0.width.equalTo(190)
        }
    }
}
