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
    
    static let reuseIdentifier = "PostsCollectionViewCell"
    
    // MARK: - Property
    
    var post: PostModel?
    
    var scrapButtonObservable: Driver<PostModel?> {
        return scrapButton.rx.tap
            .map { [weak self] in
                self?.post?.isScrapped.toggle()
                self?.updateScrapButton()
                return self?.post
            }
            .asDriver(onErrorJustReturn: nil)
    }
    
    var disposeBag = DisposeBag()

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
    private let summaryLabel: UILabel = {
        let label = UILabel()
        label.font = .body_1_M
        label.textColor = .gray500
        label.numberOfLines = 3
        return label
    }()
    private let detailView = PostDetailView()
    private let scrapButton = UIButton()
    private let tagScrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsHorizontalScrollIndicator = false
        return view
    }()
    private let tagStackView = PostTagStackView()
    
    // MARK: - Life Cycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.disposeBag = DisposeBag()
    }
    
    // MARK: - Setting
    
    override func render() {
        self.contentView.addSubviews(
            imageView,
            titleLabel,
            summaryLabel,
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
        
        summaryLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
        
        detailView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.top.equalTo(summaryLabel.snp.bottom).offset(12)
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
    
    // MARK: - Custom Method
    
    private func updateScrapButton() {
        guard let isScrapped = post?.isScrapped else { return }
        self.scrapButton.setImage(
            isScrapped ? ImageLiterals.bookMarkFill : ImageLiterals.bookMark,
            for: .normal
        )
    }
}


extension PostsCollectionViewCell {
    func loadPost(_ model: PostModel) {
        let post = model.post
        self.post = model
        self.scrapButton.setImage(model.isScrapped ? ImageLiterals.bookMarkFill : ImageLiterals.bookMark, for: .normal)
        self.titleLabel.setLineHeight(multiple: 1.3, with: post.title ?? "")
        self.summaryLabel.setLineHeight(multiple: 1.44, with: post.summary ?? "")
        self.detailView.bind(name: post.name ?? "", date: post.date ?? "")
        self.tagStackView.tagList = post.tag ?? []
        if let urlString = post.img, let url = URL(string: urlString) {
            self.imageView.kf.setImage(with: url)
        }
    }
}
