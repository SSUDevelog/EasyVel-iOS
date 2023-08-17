//
//  PostsCollectionViewCell.swift
//  EasyVel
//
//  Created by 이성민 on 2023/08/13.
//

import UIKit

import SnapKit

final class PostsCollectionViewCell: BaseCollectionViewCell {
    
    static let identifier = "PostsCollectionViewCell"
    
    // MARK: - Property
    
    
    
    // MARK: - UI Property
    
    private let imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray700
        label.font = .subhead
        return label
    }()
    
    private let textView: UITextView = {
        let view = UITextView()
        view.textColor = .gray500
        view.isEditable = false
        view.isSelectable = false
        view.isScrollEnabled = false
        view.font = .body_1_M
        return view
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray300
        label.font = .caption_1_M
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray300
        label.font = .caption_1_M
        return label
    }()
    
    let scrapButton: UIButton = {
        let button = UIButton()
        button.setImage(ImageLiterals.bookMark, for: .normal)
        // FIXME: tap scrapbutton action
        return button
    }()
    
    private let firstTag: PostTagLabel = PostTagLabel()
    private let secondTag: PostTagLabel = PostTagLabel()
    private let thirdTag: PostTagLabel = PostTagLabel()
    private lazy var tagStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [firstTag, secondTag, thirdTag])
        view.spacing = 6
        view.axis = .horizontal
        return view
    }()
    
    // MARK: - Life Cycle
    
    
    
    // MARK: - Setting
    
    override func render() {
        self.contentView.addSubviews(
            imageView,
            titleLabel,
            textView,
            dateLabel,
            nameLabel,
            scrapButton,
            tagStackView
        )
        
        imageView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(125)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(12)
            $0.height.equalTo(28)
            $0.leading.trailing.equalToSuperview().inset(15)
        }
        
        textView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(3)
            $0.leading.trailing.equalToSuperview().inset(15)
            $0.height.equalTo(60)
        }
        
        nameLabel.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(5)
            $0.height.equalTo(15)
            $0.width.equalTo(120)
            $0.leading.equalToSuperview().inset(15)
        }
        
        dateLabel.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(10)
            $0.height.equalTo(15)
            $0.trailing.equalToSuperview().inset(15)
        }
    }
    
    override func configUI() {
        self.layer.cornerRadius = 8
        self.clipsToBounds = true
    }
    
    // MARK: - Action Helper
    
    
    
    // MARK: - Custom Method
    
    
    
    
}
