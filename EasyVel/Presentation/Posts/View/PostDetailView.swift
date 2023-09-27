//
//  PostAuthorView.swift
//  EasyVel
//
//  Created by 이성민 on 2023/08/23.
//

import UIKit

import SnapKit

final class PostDetailView: BaseUIView {
    
    // MARK: - UI Property
    
    private let imageView: UIImageView = {
        let view = UIImageView(image: ImageLiterals.defaultProfileImage)
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        return view
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray300
        label.font = .caption_1_M
        return label
    }()
    
    private let divider: UILabel = {
        let label = UILabel()
        label.backgroundColor = .gray200
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray200
        label.font = .caption_1_M
        return label
    }()
    
    // MARK: - Setting
    
    override func render() {
        self.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.leading.verticalEdges.equalToSuperview()
            $0.width.height.equalTo(20)
        }
        
        self.addSubview(nameLabel)
        nameLabel.snp.makeConstraints {
            $0.leading.equalTo(imageView.snp.trailing)
            .offset(6)
            $0.centerY.equalTo(imageView)
        }
        
        self.addSubview(divider)
        divider.snp.makeConstraints {
            $0.leading.equalTo(nameLabel.snp.trailing).offset(8)
            $0.centerY.equalTo(nameLabel)
            $0.height.equalTo(12)
            $0.width.equalTo(1)
        }
        
        self.addSubview(timeLabel)
        timeLabel.snp.makeConstraints {
            $0.leading.equalTo(divider.snp.trailing).offset(8)
            $0.centerY.equalTo(divider)
        }
    }
    
    // MARK: - Custom Method
    
    func bind(
        image profileImage: UIImage? = nil,
        name nickname: String,
        date postedTime: String
    ) {
        if let image = profileImage {
            imageView.image = image
        }
        nameLabel.text = "by \(nickname)"
        timeLabel.text = postedTime
    }
    
}
