//
//  ScrapView.swift
//  VelogOnMobile
//
//  Created by 홍준혁 on 2023/05/28.
//

import UIKit

import SnapKit

protocol ScrapPopUpDelegate: AnyObject {
    func goToScrapButtonDidTap()
    func putInFolderButtonDidTap(scrapPost: StoragePost)
}

final class ScrapPopUpView: BaseUIView {
    
    // MARK: - Properties
    
    weak var delegate: ScrapPopUpDelegate?
    private var storagePost: StoragePost
    
    // MARK: - UI Components
    
    init(storagePost: StoragePost) {
        self.storagePost = storagePost
        
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let lineView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray200
        return view
    }()
    
    private let scrapLabel: UILabel = {
        let label = UILabel()
        label.text = TextLiterals.scrapPopUpViewLeftText
        label.textColor = .gray500
        label.font = .body_2_M
        return label
    }()
    
    lazy var goToStorageButton: UIButton = {
        let button = UIButton()
        button.setTitle(TextLiterals.moveToScrapStorageButtonText, for: .normal)
        button.setTitleColor(UIColor.brandColor, for: .normal)
        button.titleLabel?.font = .body_1_B
        button.backgroundColor = .white
        button.makeRoundBorder(cornerRadius: 5, borderWidth: 1, borderColor: .brandColor)
        button.addTarget(self, action: #selector(goToScrapButtonDidTap), for: .touchUpInside)
        return button
    }()
    
    lazy var putInFolderButton: UIButton = {
        let button = UIButton()
        button.setTitle(TextLiterals.presentScrapFolderBottomSheetButtonText, for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = .body_1_B
        button.backgroundColor = .brandColor
        button.makeRoundBorder(cornerRadius: 5, borderWidth: 1, borderColor: .brandColor)
        button.addTarget(self, action: #selector(putInFolderButtonDidTap), for: .touchUpInside)
        return button
    }()

    override func render() {
        self.backgroundColor = .white
    }
    
    override func configUI() {
        self.addSubviews(
            lineView,
            scrapLabel,
            goToStorageButton,
            putInFolderButton
        )
        
        lineView.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        scrapLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.top.equalToSuperview().inset(18)
        }
        
        putInFolderButton.snp.makeConstraints {
            $0.centerY.equalTo(self.scrapLabel)
            $0.height.equalTo(32)
            $0.width.equalTo(88)
            $0.trailing.equalToSuperview().inset(20)
        }
        
        goToStorageButton.snp.makeConstraints {
            $0.centerY.equalTo(self.scrapLabel)
            $0.height.equalTo(32)
            $0.width.equalTo(72)
            $0.trailing.equalTo(putInFolderButton.snp.leading).offset(-10)
        }
    }
    
    public func getPostData(post: StoragePost) {
        storagePost = post
    }
}

private extension ScrapPopUpView {
    @objc
    func goToScrapButtonDidTap() {
        delegate?.goToScrapButtonDidTap()
    }
    
    @objc
    func putInFolderButtonDidTap() {
        delegate?.putInFolderButtonDidTap(scrapPost: storagePost)
    }
}
