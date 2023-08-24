//
//  KeywordsTableViewCell.swift
//  VelogOnMobile
//
//  Created by 홍준혁 on 2023/04/30.
//

import UIKit

import SnapKit
import Kingfisher

final class PostsTableViewCell: BaseTableViewCell {
    
    static let identifier = "PostsTableViewCell"
    
    weak var cellDelegate: PostScrapButtonDidTapped?
    weak var scrapPostAddInFolderDelegate: ScrapPostAddInFolderProtocol?
    var isTapped: Bool = false {
        didSet {
            updateButton()
        }
    }
    var cellIndex: Int?
    var post: PostDTO?
    var url = String()
    
    private let imgView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let title: UILabel = {
        let title = UILabel()
        title.textColor = .gray700
        title.font = .subhead
        return title
    }()
    
    private let textView: UITextView = {
        let textView = UITextView()
        textView.textColor = .gray500
        textView.isEditable = false
        textView.isSelectable = false
        textView.isScrollEnabled = false
        textView.font = .body_1_M
        return textView
    }()

    private let date: UILabel = {
        let label = UILabel()
        label.textColor = .gray300
        label.font = .caption_1_M
        return label
    }()
    
    private let name: UILabel = {
        let label = UILabel()
        label.textColor = .gray300
        label.font = .caption_1_M
        return label
    }()
    
    let scrapButton : UIButton = {
        let button = UIButton()
        button.setImage(ImageLiterals.bookMark, for: .normal)
        return button
    }()
    
    private let tagScrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsHorizontalScrollIndicator = false
        return view
    }()
    
    private let tagStackView = PostTagStackView()
    
    // MARK: - life cycle
    
    override func render() {
        self.scrapButton.addTarget(self, action: #selector(scrapButtonTapped), for: .touchUpInside)
        
        self.contentView.addSubviews(
            imgView,
            date,
            name,
            title,
            textView,
            tagScrollView,
            scrapButton
        )
        
        scrapButton.snp.makeConstraints {
            $0.height.width.equalTo(44)
            $0.top.trailing.equalToSuperview().inset(4)
        }
        
        tagScrollView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(10)
            $0.leading.equalToSuperview().inset(12)
            $0.trailing.equalTo(scrapButton.snp.leading).offset(-12)
            $0.height.equalTo(28)
        }
        
        tagScrollView.addSubview(tagStackView)
        tagStackView.snp.makeConstraints {
            $0.edges.height.equalToSuperview()
        }
        
        imgView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(100)
        }
        
        title.snp.makeConstraints {
            $0.top.equalTo(imgView.snp.bottom).offset(15)
            $0.height.equalTo(28)
            $0.leading.trailing.equalToSuperview().inset(15)
        }
        
        textView.snp.makeConstraints {
            $0.top.equalTo(title.snp.bottom).offset(3)
            $0.leading.trailing.equalToSuperview().inset(15)
            $0.height.equalTo(60)
        }
        
        name.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(5)
            $0.height.equalTo(15)
            $0.width.equalTo(120)
            $0.leading.equalToSuperview().inset(15)
        }
        contentView.bringSubviewToFront(name)
        
        date.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(10)
            $0.height.equalTo(15)
            $0.trailing.equalToSuperview().inset(15)
        }
        contentView.bringSubviewToFront(date)
    }
    
    func updateButton() {
        let image = isTapped ? ImageLiterals.bookMarkFill : ImageLiterals.bookMark
        scrapButton.setImage(image, for: .normal)
    }
    
    @objc
    func scrapButtonTapped(_ sender: UIButton) {
        if !(isTapped) {
            if let scrapPost = post {
                let storagePost = StoragePost(
                    img: scrapPost.img,
                    name: scrapPost.name,
                    summary: scrapPost.summary,
                    title: scrapPost.title,
                    url: scrapPost.url
                )
                NotificationCenter.default.post(
                    name: Notification.Name("ScrapButtonTappedNotification"),
                    object: nil,
                    userInfo: ["data": storagePost]
                )
            }
        }
        guard let post = post else { return }
        let storagePost = StoragePost(
            img: post.img,
            name: post.name,
            summary: post.summary,
            title: post.title,
            url: post.url
        )
        if let index = cellIndex {
            cellDelegate?.scrapButtonDidTapped(
                storagePost: storagePost,
                isScrapped: isTapped,
                cellIndex: index
            )
        }
        self.isTapped.toggle()
    }
}

extension PostsTableViewCell {
    public func binding(model: PostDTO){
        post = model
        title.text = model.title
        name.text = model.name
        date.text = model.date
        url = model.url ?? String()
        textView.text = model.summary
        
        if textView.text == TextLiterals.noneText {
            textView.isHidden = true
        }
        
        if let image = model.img {
            if image == TextLiterals.noneText {
                imgView.isHidden = true
                title.snp.remakeConstraints {
                    $0.height.equalTo(45)
                    $0.leading.trailing.equalToSuperview().inset(15)
                }
            } else {
                let url = URL(string: image)
                imgView.kf.setImage(with: url)
            }
        }
        
        guard let tagList = model.tag else { return }
        tagStackView.tagList = tagList
    }
    
    override func prepareForReuse() {
        imgView.isHidden = false
        textView.isHidden = false

        title.snp.remakeConstraints {
            $0.top.equalTo(imgView.snp.bottom).offset(15)
            $0.height.equalTo(45)
            $0.leading.trailing.equalToSuperview().inset(15)
        }
    }
}
