//
//  ScrapView.swift
//  VelogOnMobile
//
//  Created by 홍준혁 on 2023/05/28.
//

import UIKit

import SnapKit

final class ScrapPopUpView: BaseUIView {
    
    // MARK: - UI Components
    
    private let ScrapLabel: UILabel = {
        let label = UILabel()
        label.text = "스크랩했습니다."
        label.textColor = .black
        label.font = UIFont(name: "Avenir-Black", size: 15)
        return label
    }()
    
    private lazy var moveToStorageButton: UIButton = {
        let button = UIButton()
        button.setTitle("보러가기", for: .normal)
        button.setTitleColor(UIColor.brandColor, for: .normal)
        button.titleLabel?.font = UIFont(name: "Avenir-Black", size: 15)
        button.backgroundColor = .white
        button.makeRoundBorder(cornerRadius: 5, borderWidth: 1, borderColor: .brandColor)
        return button
    }()
    
    private lazy var addToFolderButton: UIButton = {
        let button = UIButton()
        button.setTitle("폴더에 담기", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "Avenir-Black", size: 15)
        button.backgroundColor = .brandColor
        button.makeRoundBorder(cornerRadius: 5, borderWidth: 1, borderColor: .brandColor)
        return button
    }()

    override func render() {
        self.backgroundColor = .white
    }
    
    override func configUI() {
        self.addSubviews(ScrapLabel,
                         moveToStorageButton,
                         addToFolderButton)
        
        ScrapLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.top.equalToSuperview().inset(12)
        }
        
        addToFolderButton.snp.makeConstraints {
            $0.top.equalToSuperview().inset(9)
            $0.height.equalTo(30)
            $0.width.equalTo(88)
            $0.trailing.equalToSuperview().inset(20)
        }
        
        moveToStorageButton.snp.makeConstraints {
            $0.top.equalToSuperview().inset(9)
            $0.height.equalTo(30)
            $0.width.equalTo(72)
            $0.trailing.equalTo(addToFolderButton.snp.leading).offset(-10)
        }
    }
}
