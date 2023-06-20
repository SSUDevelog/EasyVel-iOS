//
//  ScarpView.swift
//  VelogOnMobile
//
//  Created by 홍준혁 on 2023/05/29.
//

import UIKit

import SnapKit

final class ScrapStorageView: BaseUIView {

    // MARK: - UI Components
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Scrap"
        label.textColor = .gray700
        label.font = UIFont(name: "Avenir-Black", size: 24)
        return label
    }()
    
    private let vertiLineView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray200
        return view
    }()
    
    let addFolderButton: UIButton = {
        let button = UIButton()
        button.setTitle("폴더 추가", for: .normal)
        button.setTitleColor(.gray300, for: .normal)
        button.titleLabel?.font = UIFont(name: "Avenir-Black", size: 16)
        button.backgroundColor = .gray100
        return button
    }()
    
    let scrapCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: (SizeLiterals.screenWidth - 40) / 2, height: 96)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(cell: ScrapStorageCollectionViewCell.self)
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        collectionView.showsVerticalScrollIndicator = true
        collectionView.backgroundColor = .gray100
        return collectionView
    }()
    
    override func configUI() {
        self.backgroundColor = .gray100
    }
    
    override func render() {
        self.addSubviews(
            titleLabel,
            vertiLineView,
            addFolderButton,
            scrapCollectionView
        )
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(76)
            $0.leading.equalToSuperview().offset(20)
        }
        
        vertiLineView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(171)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        addFolderButton.snp.makeConstraints {
            $0.top.equalTo(vertiLineView.snp.bottom).offset(16)
            $0.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(30)
            $0.width.equalTo(80)
        }
        
        scrapCollectionView.snp.makeConstraints {
            $0.top.equalTo(addFolderButton.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
    
    func scrapCollectionViewStartScroll() {
        UIView.animate(withDuration: 4, animations: {
            self.addFolderButton.snp.remakeConstraints {
                $0.top.equalTo(self.vertiLineView.snp.bottom)
                $0.trailing.equalToSuperview().inset(20)
                $0.height.equalTo(0)
                $0.width.equalTo(0)
            }
            self.scrapCollectionView.snp.remakeConstraints {
                $0.top.equalTo(self.vertiLineView.snp.bottom)
                $0.leading.trailing.equalToSuperview()
                $0.bottom.equalToSuperview()
            }
        }, completion: { isCompleted in
            self.layoutIfNeeded()
        })
    }
    
    func scrapCollectionViewEndScroll() {
        UIView.animate(withDuration: 4, animations: {
            self.addFolderButton.snp.remakeConstraints {
                $0.top.equalTo(self.vertiLineView.snp.bottom).offset(16)
                $0.trailing.equalToSuperview().inset(20)
                $0.height.equalTo(30)
                $0.width.equalTo(80)
            }
            self.scrapCollectionView.snp.remakeConstraints {
                $0.top.equalTo(self.addFolderButton.snp.bottom).offset(16)
                $0.leading.trailing.equalToSuperview()
                $0.bottom.equalToSuperview()
            }
        }, completion: { isCompleted in
            self.layoutIfNeeded()
        })
    }
}
