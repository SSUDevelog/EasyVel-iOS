//
//  DeleteFolderBottomSheet.swift
//  EasyVel
//
//  Created by 이성민 on 11/1/23.
//

import UIKit

final class DeleteFolderBottomSheet: BaseUIView {
    
    // MARK: - Property
    
    // MARK: - UI Property
    
    let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(ImageLiterals.closeIcon, for: .normal)
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = TextLiterals.storageViewDeleteFolderButtonText
        label.font = .subhead
        label.textColor = .gray700
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.setLineHeight(multiple: 1.44)
        label.text = TextLiterals.deleteFolderActionSheetMessage
        label.font = .body_1_M
        label.textColor = .gray300
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()
    
    let cancelButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .gray100
        button.setTitle(TextLiterals.deleteFolderActionSheetCancelActionText, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .body_1_B
        button.makeRounded(radius: 5)
        return button
    }()
    
    let deleteButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .brandColor
        button.setTitle(TextLiterals.deleteFolderActionSheetOkActionText, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .body_1_B
        button.makeRounded(radius: 5)
        return button
    }()
    
    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [cancelButton, deleteButton])
        stackView.axis = .horizontal
        stackView.spacing = 13
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    // MARK: - Life Cycle
    
    // MARK: - Setting
    
    override func render() {
        self.addSubview(closeButton)
        closeButton.snp.makeConstraints {
            $0.top.equalToSuperview().inset(22)
            $0.trailing.equalToSuperview().inset(20)
        }
        
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.centerY.equalTo(self.closeButton)
            $0.centerX.equalToSuperview()
        }
        
        self.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(self.titleLabel.snp.bottom).offset(27)
            $0.centerX.equalToSuperview()
        }
        
        self.addSubview(buttonStackView)
        buttonStackView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.top.equalTo(self.descriptionLabel.snp.bottom).offset(24)
            $0.bottom.equalToSuperview().inset(47)
            $0.height.equalTo(44)
        }
    }
    
    override func configUI() {
        self.backgroundColor = .white
        self.makeRounded(radius: 12)
    }
}
