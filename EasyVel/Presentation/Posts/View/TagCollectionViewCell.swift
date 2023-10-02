//
//  TagCollectionViewCell.swift
//  EasyVel
//
//  Created by 이성민 on 10/2/23.
//

import UIKit

import SnapKit

struct TagModel: Identifiable, Hashable {
    let id = UUID()
    let tag: String
}

final class TagCollectionViewCell: UICollectionViewCell {
    
    let tagLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .body_1_M
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        self.render()
        self.configUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func render() {
        self.contentView.addSubview(tagLabel)
        tagLabel.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(12)
            $0.height.equalTo(28)
        }
    }
    
    private func configUI() {
        self.backgroundColor = .brandColor
        self.layer.cornerRadius = 14
        self.clipsToBounds = true
    }
    
    func loadTag(_ data: TagModel) {
        tagLabel.text = data.tag
    }
}

