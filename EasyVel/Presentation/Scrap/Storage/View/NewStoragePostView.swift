//
//  NewStorageView.swift
//  EasyVel
//
//  Created by 이성민 on 10/9/23.
//

import UIKit

import RxCocoa

final class NewStoragePostView: BaseUIView {
    
    // MARK: - Property
    
    var title: String?
    
    var dismissTrigger: Driver<Void> {
        let closeButtonTrigger = self.bottomSheet.closeButton.rx.tap.asDriver()
        let cancelButtonTrigger = self.bottomSheet.cancelButton.rx.tap.asDriver()
        return Driver.merge([
            closeButtonTrigger,
            cancelButtonTrigger
        ])
    }
    
    var deleteFolderTrigger: Driver<String?> {
        return bottomSheet.deleteButton.rx.tap
            .map { return self.title }
            .asDriver(onErrorJustReturn: nil)
    }
    
    // MARK: - UI Property
    
    private let navigationBarView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    private lazy var navigationTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray500
        label.font = .body_2_B
        return label
    }()
    private let navigationLineView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray200
        return view
    }()
    let backButton: UIButton = {
        let button = UIButton()
        button.setImage(ImageLiterals.viewPopButtonIcon, for: .normal)
        return button
    }()
    let collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        collectionView.backgroundColor = .gray100
        return collectionView
    }()
    
    lazy var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0)
        return view
    }()
    lazy var bottomSheet = DeleteFolderBottomSheet()
    
    // MARK: - Life Cycle
    
    // MARK: - Setting
    
    override func render() {
        self.addSubview(navigationBarView)
        navigationBarView.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview()
            $0.height.equalTo(130)
        }
        
        navigationBarView.addSubview(backButton)
        backButton.snp.makeConstraints {
            $0.size.equalTo(44)
            $0.leading.equalToSuperview().inset(3)
            $0.bottom.equalToSuperview().inset(18)
        }
        
        navigationBarView.addSubview(navigationTitleLabel)
        navigationTitleLabel.snp.makeConstraints {
            $0.centerY.equalTo(self.backButton)
            $0.centerX.equalToSuperview()
        }
        
        navigationBarView.addSubview(navigationLineView)
        navigationLineView.snp.makeConstraints {
            $0.top.equalTo(navigationBarView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        self.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.top.equalTo(navigationBarView.snp.bottom).offset(1)
            $0.horizontalEdges.bottom.equalToSuperview()
        }
    }
    
    override func configUI() {
        self.backgroundColor = .gray200
        self.collectionView.collectionViewLayout = createLayout()
        self.collectionView.register(
            StorageCollectionViewHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: StorageCollectionViewHeader.reuseIdentifier
        )
    }
}

extension NewStoragePostView {
    
    func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { _, _ in
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(325)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(325)
            )
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 20
            section.boundarySupplementaryItems = [self.createHeader()]
            section.contentInsets = .init(top: 0, leading: 20, bottom: 24, trailing: 20)
            
            return section
        }
    }
    
    func createHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(56)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        return header
    }
}

extension NewStoragePostView {
    
    func configureNavigationTitle(to title: String) {
        self.navigationTitleLabel.text = title
    }
}

extension NewStoragePostView {
    
    func showDeleteFolderBottomSheet() {
        self.renderDeleteFolderBottomSheet()
        self.animateDeleteFolderBottomSheet()
    }
    
    private func renderDeleteFolderBottomSheet() {
        self.addSubview(backgroundView)
        backgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        backgroundView.addSubview(bottomSheet)
        bottomSheet.snp.makeConstraints {
            $0.top.equalTo(self.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
        }
    }
    
    private func animateDeleteFolderBottomSheet() {
        UIView.animate(withDuration: 0.2) {
            self.backgroundView.backgroundColor = .black.withAlphaComponent(0.45)
            self.bottomSheet.transform = .init(translationX: 0, y: -238)
        }
    }
    
    func dismissDeleteFolderBottomSheet() {
        UIView.animate(withDuration: 0.2, animations: {
            self.backgroundView.backgroundColor = .black.withAlphaComponent(0)
            self.bottomSheet.transform = .identity
        }, completion: { _ in
            self.backgroundView.removeFromSuperview()
            self.bottomSheet.removeFromSuperview()
        })
    }
}
