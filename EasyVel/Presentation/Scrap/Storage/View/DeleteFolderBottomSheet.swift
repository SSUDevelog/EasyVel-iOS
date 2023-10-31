//
//  DeleteFolderBottomSheet.swift
//  EasyVel
//
//  Created by 이성민 on 11/1/23.
//

import UIKit

import SnapKit

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
        label.text = TextLiterals.deleteFolderActionSheetMessage
        label.font = .body_1_M
        label.textColor = .gray300
        return label
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .gray100
        button.setTitle(TextLiterals.deleteFolderActionSheetCancelActionText, for: .normal)
        button.titleLabel?.textColor = .gray300
        return button
    }()
    
    private let deleteButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .brandColor
        button.setTitle(TextLiterals.deleteFolderActionSheetCancelActionText, for: .normal)
        button.titleLabel?.textColor = .white
        return button
    }()
    
    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [cancelButton, deleteButton])
        stackView.axis = .horizontal
        stackView.spacing = 13
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
            $0.top.equalTo(self.descriptionLabel).offset(24)
            $0.bottom.equalToSuperview().inset(47)
        }
    }
    
    override func configUI() {}
    
    // MARK: - Action Helper
    
    
    
    // MARK: - Custom Method
    
    
    
}
