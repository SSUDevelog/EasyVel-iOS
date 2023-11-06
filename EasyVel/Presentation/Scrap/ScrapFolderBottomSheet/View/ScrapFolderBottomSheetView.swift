//
//  ScrapFolderBottomSheetView.swift
//  VelogOnMobile
//
//  Created by 홍준혁 on 2023/05/28.
//

import UIKit

import SnapKit

final class ScrapFolderBottomSheetView: BaseUIView {
    
    var isAddFolderButtonTapped: Bool = false {
        didSet {
            updateIsHidden()
        }
    }
    
    var isStartWriting: Bool = false {
        didSet {
            updateAddFolderFinishedButton()
        }
    }
    
    // MARK: - UI Components
    
    private let bottomSheetView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = TextLiterals.bottomSheetText
        label.textAlignment = .center
        label.textColor = .gray700
        label.font = .subhead
        return label
    }()
    
    let cancelButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .gray700
        return button
    }()
    
    let newFolderButton: UIButton = {
        let button = UIButton()
        button.setImage(ImageLiterals.plusFolder, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 4
        button.layer.masksToBounds = true
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()
    
    private let folderTitleLabel: UILabel = {
        let label = UILabel()
        label.text = TextLiterals
            .makeNewFolderButtonText
        label.textColor = .gray300
        label.font = .body_2_B
        return label
    }()
    
    let folderTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(cell: ScrapFolderBottomSheetTableViewCell.self)
        tableView.backgroundColor = .white
        tableView.showsVerticalScrollIndicator = false
        tableView.rowHeight = 46
        tableView.separatorStyle = .none
        return tableView
    }()
    
    // MARK: - isHidden view component
    
    let newFolderAddTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = TextLiterals.newFolderAddTextFieldPlaceholder
        textField.isHidden = true
        textField.addLeftPadding(leftPaddingWidth: 10)
        return textField
    }()
    
    let addFolderFinishedButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .gray100
        button.setTitle(TextLiterals.addFolderFinishedButtonTitleText, for: .normal)
        button.titleLabel?.font = .body_1_M
        button.setTitleColor(.gray300, for: .normal)
        button.layer.cornerRadius = 5
        button.isHidden = true
        return button
    }()
    
    // MARK: - Functions
    
    override func configUI() {
        self.backgroundColor = .white
    }
    
    override func render() {
        self.addSubviews(bottomSheetView)
        bottomSheetView.addSubviews(
            titleLabel,
            cancelButton,
            newFolderButton,
            newFolderAddTextField,
            addFolderFinishedButton,
            folderTitleLabel,
            folderTableView
        )
        
        bottomSheetView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(12)
            $0.centerX.equalToSuperview()
        }
        
        cancelButton.snp.makeConstraints {
            $0.size.equalTo(16)
            $0.top.trailing.equalToSuperview().inset(18)
        }
        
        newFolderButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(60)
            $0.leading.equalToSuperview().inset(20)
            $0.width.equalTo(36)
            $0.height.width.equalTo(30)
        }
        
        folderTitleLabel.snp.makeConstraints {
            $0.centerY.equalTo(newFolderButton)
            $0.leading.equalTo(newFolderButton.snp.trailing).offset(10)
        }
        
        folderTableView.snp.makeConstraints {
            $0.top.equalTo(newFolderButton.snp.bottom).offset(15)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        // MARK: - isHidden view components
        
        newFolderAddTextField.snp.makeConstraints {
            $0.centerY.equalTo(newFolderButton)
            $0.leading.equalTo(newFolderButton.snp.trailing).offset(10)
            $0.height.equalTo(32)
        }
        
        addFolderFinishedButton.snp.makeConstraints {
            $0.centerY.equalTo(newFolderButton)
            $0.height.equalTo(32)
            $0.width.equalTo(49)
            $0.leading.equalTo(newFolderAddTextField.snp.trailing).offset(20)
            $0.trailing.equalToSuperview().inset(20)
        }
    }
    
    private func updateIsHidden() {
        if isAddFolderButtonTapped {
            newFolderAddTextField.isHidden = false
            addFolderFinishedButton.isHidden = false
            folderTitleLabel.isHidden = true
            newFolderButton.setImage(ImageLiterals.folderGreen, for: .normal)
        } else {
            newFolderAddTextField.isHidden = true
            addFolderFinishedButton.isHidden = true
            folderTitleLabel.isHidden = false
            newFolderButton.setImage(ImageLiterals.plusFolder, for: .normal)
        }
    }
    
    private func updateAddFolderFinishedButton() {
        let addFolderFinishedButtonBackgroundColor: UIColor = isStartWriting ? .brandColor : .gray100
        let addFolderFinishedButtonTintColor: UIColor = isStartWriting ? .white : .gray300
        addFolderFinishedButton.backgroundColor = addFolderFinishedButtonBackgroundColor
        addFolderFinishedButton.setTitleColor(addFolderFinishedButtonTintColor, for: .normal)
    }
}
