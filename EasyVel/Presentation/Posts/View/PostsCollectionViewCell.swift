//
//  PostsCollectionViewCell.swift
//  EasyVel
//
//  Created by 이성민 on 2023/08/13.
//

import UIKit

import SnapKit
import RxSwift
import RxCocoa

final class PostsCollectionViewCell: BaseCollectionViewCell {
    
    static let identifier = "PostsCollectionViewCell"
    
    // MARK: - Property
    
    var cellScrapObservable: Observable<(IndexPath, Bool)>?
    var post: PostDTO?
    var isScrapped: Bool = false
    
    // MARK: - UI Property
    
    private let imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.roundCorners(cornerRadius: 8, maskedCorners: [.layerMaxXMinYCorner, .layerMinXMinYCorner])
        return view
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray700
        label.font = .subhead
        label.numberOfLines = 2
        return label
    }()
    private let textView: UITextView = {
        let view = UITextView()
        view.textColor = .gray500
        view.isEditable = false
        view.isSelectable = false
        view.isScrollEnabled = false
        view.textContainer.lineFragmentPadding = 0
        view.font = .body_1_M
        return view
    }()
    private let detailView = PostDetailView()
    lazy var scrapButton: UIButton = {
        let button = UIButton()
        button.setImage(isScrapped ? ImageLiterals.bookMarkFill : ImageLiterals.bookMark,for: .normal)
        button.addAction(UIAction { _ in
            
        }, for: .touchUpInside)
        return button
    }()
    private let tagScrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsHorizontalScrollIndicator = false
        return view
    }()
    private let tagStackView = PostTagStackView()
    
    // MARK: - Life Cycle
    
    
    
    // MARK: - Setting
    
    override func render() {
        self.contentView.addSubviews(
            imageView,
            titleLabel,
            textView,
            detailView,
            scrapButton,
            tagScrollView,
            tagStackView
        )
        
        imageView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(125)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(12)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
        
        textView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
        
        detailView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.top.equalTo(textView.snp.bottom).offset(12)
            $0.bottom.equalToSuperview().inset(16)
        }
        
        scrapButton.snp.makeConstraints {
            $0.height.width.equalTo(44)
            $0.top.trailing.equalToSuperview().inset(4)
        }
        
        tagScrollView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(12)
            $0.trailing.equalTo(scrapButton.snp.leading).offset(-12)
            $0.top.equalToSuperview().inset(10)
            $0.height.equalTo(28)
        }
        
        tagScrollView.addSubview(tagStackView)
        tagStackView.snp.makeConstraints {
            $0.edges.height.equalToSuperview()
        }
    }
    
    override func configUI() {
        self.contentView.backgroundColor = .white
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
        self.backgroundView = UIView()
        self.backgroundView?.layer.shadowOffset = .init(width: 0, height: 0)
        self.backgroundView?.layer.shadowOpacity = 0.8
        self.backgroundView?.layer.shadowRadius = 2
    }
    
    // MARK: - Custom Method
    
    
    
    
}

extension PostsCollectionViewCell {
    func loadPost(_ model: PostModel, _ indexPath: IndexPath) {
        guard let post = model.post else { return }
        self.post = post
        self.titleLabel.text = post.title
        self.textView.text = post.summary
        
        if let urlString = post.img,
           let url = URL(string: urlString),
           let name = post.name,
           let date = post.date {
            self.imageView.kf.setImage(with: url)
            self.detailView.bind(name: name,
                                 date: date)
        }
    }
}
