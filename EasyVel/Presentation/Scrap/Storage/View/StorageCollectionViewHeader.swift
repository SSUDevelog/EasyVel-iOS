//
//  StorageCollectionViewHeader.swift
//  EasyVel
//
//  Created by 이성민 on 10/9/23.
//

import UIKit

import RxSwift
import RxCocoa

final class StorageCollectionViewHeader: UICollectionReusableView {
    
    // MARK: - Property
    
    var changeNameButtonTrigger: Driver<Void> {
        return self.changeNameButton.rx.tap.asDriver()
    }
    
    var deleteFolderButtonTrigger: Driver<Void> {
        return self.deleteFolderButton.rx.tap.asDriver()
    }
    
    // MARK: - UI Property
    
    private let changeNameButton: UIButton = {
        let button = UIButton()
        return button
    }()
    private let deleteFolderButton: UIButton = {
        let button = UIButton()
        return button
    }()
    private let separator: UIView = {
        let view = UIView(frame: .init(x: 0, y: 0, width: 1, height: 16))
        
        return view
    }()
    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [changeNameButton, separator, deleteFolderButton])
        stackView.axis = .horizontal
        stackView.spacing = 16
        return stackView
    }()
    
    // MARK: - Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        self.render()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setting
    
    private func render() {
        self.addSubview(buttonStackView)
        buttonStackView.snp.makeConstraints {
            $0.trailing.centerY.equalToSuperview()
        }
    }
}
