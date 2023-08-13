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
    
    private let firstTag: PostTagUIButton = PostTagUIButton()
    private let secondTag: PostTagUIButton = PostTagUIButton()
    private let thirdTag: PostTagUIButton = PostTagUIButton()
    private lazy var tagStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [firstTag, secondTag, thirdTag])
        view.spacing = 6
        view.axis = .horizontal
        return view
    }()
    
    // MARK: - Life Cycle
    
    
    
    // MARK: - Setting
    
    
    
    // MARK: - Action Helper
    
    
    
    // MARK: - Custom Method
    
    
    
    
}
