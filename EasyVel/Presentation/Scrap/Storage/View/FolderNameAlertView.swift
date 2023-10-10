//
//  FolderNameAlertView.swift
//  EasyVel
//
//  Created by 이성민 on 10/10/23.
//

import UIKit

import SnapKit

enum FolderAlertType {
    case create
    case change
    
    var title: String {
        switch self {
        case .create: "폴더 추가"
        case .change: "폴더 이름 변경"
        }
    }
}

final class FolderNameAlertView: BaseUIView {
    
    // MARK: - Property
    
    let alertType: FolderAlertType
    
    // MARK: - UI Property
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = self.alertType.title
        label.font = .subhead
        label.textColor = .gray700
        return label
    }()
    private lazy var textField = UITextField()
    private let dismissButton: UIButton = {
        let button = UIButton()
        button.setTitle("취소", for: .normal)
        button.setTitleColor(.gray300, for: .normal)
        button.titleLabel?.font = .body_2_M
        button.backgroundColor = .gray100
        return button
    }()
    private let confirmButton: UIButton = {
        let button = UIButton()
        button.setTitle("확인", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .body_2_M
        button.backgroundColor = .brandColor
        return button
    }()
    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [dismissButton, confirmButton])
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.distribution = .fillEqually
        return stackView
    }()
    let alertLabel: UILabel = {
        let label = UILabel()
        label.text = TextLiterals.existingFolder
        label.font = .caption_1_M
        label.textColor = .error
        label.isHidden = true
        return label
    }()
    
    // MARK: - Life Cycle
    
    init(alertType: FolderAlertType) {
        self.alertType = alertType
        super.init(frame: .zero)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setting
    
    override func render() {
        self.snp.makeConstraints {
            $0.width.equalTo(299)
        }
        
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.centerX.equalToSuperview()
        }
        self.addSubview(textField)
        textField.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(36)
        }
        self.addSubview(buttonStackView)
        buttonStackView.snp.makeConstraints {
            $0.top.equalTo(textField.snp.bottom).offset(48)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
    }
    
    override func configUI() {
        
    }
}

