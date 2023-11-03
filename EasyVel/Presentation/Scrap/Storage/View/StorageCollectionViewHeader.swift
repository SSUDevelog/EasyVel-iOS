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
    
    var disposeBag = DisposeBag()
    
    var changeNameButtonTrigger: Driver<Void> {
        return self.changeNameButton.rx.tap.asDriver()
    }
    
    var deleteFolderButtonTrigger: Driver<Void> {
        return self.deleteFolderButton.rx.tap.asDriver()
    }
    
    // MARK: - UI Property
    
    private let changeNameButton: UIButton = {
        let button = UIButton()
        button.setTitle("이름 변경", for: .normal)
        button.setTitleColor(.gray300, for: .normal)
        button.titleLabel?.font = .body_2_B
        return button
    }()
    private let separator: UIView = {
        let view = UIView()
        view.backgroundColor = .gray200
        return view
    }()
    private let deleteFolderButton: UIButton = {
        let button = UIButton()
        button.setTitle("폴더 삭제", for: .normal)
        button.setTitleColor(.gray300, for: .normal)
        button.titleLabel?.font = .body_2_B
        return button
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
        separator.snp.makeConstraints {
            $0.width.equalTo(1)
            $0.height.equalTo(16)
        }
        
        self.addSubview(buttonStackView)
        buttonStackView.snp.makeConstraints {
            $0.trailing.centerY.equalToSuperview()
        }
    }
}
