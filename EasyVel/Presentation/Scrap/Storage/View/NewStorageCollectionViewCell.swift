//
//  NewStorageCollectionViewCell.swift
//  EasyVel
//
//  Created by 이성민 on 10/9/23.
//

import UIKit

import Kingfisher
import SnapKit
import RxSwift
import RxCocoa

final class NewStorageCollectionViewCell: BaseCollectionViewCell {
    
    // MARK: - Property
    
    static let identifier = "NewStorageCollectionViewCell"
    
    var post: StoragePost?
    var isScrapped: Bool = true
    var disposeBag = DisposeBag()
    
    var deleteStoragePostTrigger: Driver<String> {
        return self.scrapButton.rx.tap
            .map {
                self.isScrapped.toggle()
                self.updateScrapButton()
                return self.post?.url ?? ""
            }
            .asDriver(onErrorJustReturn: String())
    }
    
    // MARK: - UI Property
    
    private let postImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.roundCorners(cornerRadius: 8, maskedCorners: [.layerMaxXMinYCorner, .layerMinXMinYCorner])
        return imageView
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.setLineHeight(multiple: 1.3)
        label.textColor = .gray700
        label.font = .subhead
        label.numberOfLines = 2
        return label
    }()
    private let summaryLabel: UILabel = {
        let label = UILabel()
        label.setLineHeight(multiple: 1.44)
        label.font = .body_1_M
        label.textColor = .gray500
        label.numberOfLines = 3
        return label
    }()
    private let authorImageView: UIImageView = {
        let imageView = UIImageView(image: ImageLiterals.defaultProfileImage)
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
        return imageView
    }()
    private let authorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray300
        label.font = .caption_1_M
        return label
    }()
    private let scrapButton: UIButton = {
        let button = UIButton()
        button.setImage(ImageLiterals.bookMarkFill, for: .normal)
        return button
    }()
    
    // MARK: - Life Cycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.disposeBag = DisposeBag()
    }
    
    // MARK: - Setting
    
    override func render() {
        self.contentView.addSubview(postImageView)
        postImageView.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview()
            $0.height.equalTo(125)
        }
        self.contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(postImageView.snp.bottom).offset(12)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
        self.contentView.addSubview(summaryLabel)
        summaryLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
        self.contentView.addSubview(authorImageView)
        authorImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.top.equalTo(summaryLabel.snp.bottom).offset(12)
            $0.bottom.equalToSuperview().inset(16)
        }
        self.contentView.addSubview(authorLabel)
        authorLabel.snp.makeConstraints {
            $0.leading.equalTo(authorImageView.snp.trailing).offset(6)
            $0.centerY.equalTo(authorImageView)
        }
        self.contentView.addSubview(scrapButton)
        scrapButton.snp.makeConstraints {
            $0.height.width.equalTo(44)
            $0.top.trailing.equalToSuperview().inset(4)
        }
    }
    
    override func configUI() {
        let background = UIView(frame: self.bounds)
        background.backgroundColor = .white
        background.layer.cornerRadius = 8
        background.layer.masksToBounds = true
        self.backgroundView = background
        self.layer.shadowOffset = .zero
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.08
        self.layer.shadowRadius = 10
    }
}

extension NewStorageCollectionViewCell {
    private func updateScrapButton() {
        self.scrapButton.setImage(
            self.isScrapped ? ImageLiterals.bookMarkFill : ImageLiterals.bookMark,
            for: .normal
        )
    }
}

extension NewStorageCollectionViewCell {
    func loadPost(_ post: StoragePost) {
        self.post = post
        
        if let title = post.title,
           let summary = post.summary,
           let author = post.name {
            self.titleLabel.text = title
            self.summaryLabel.text = summary
            self.authorLabel.text = author
        }
        
        if let urlString = post.img, let url = URL(string: urlString) {
            self.postImageView.kf.setImage(with: url)
        } else {
            self.postImageView.image = UIImage(named: "default.post")
        }
    }
}
