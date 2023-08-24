//
//  PostTagStackView.swift
//  EasyVel
//
//  Created by 이성민 on 2023/08/23.
//

import UIKit

import SnapKit

final class PostTagStackView: UIStackView {
    
    // MARK: - Property
    
    var tagList: [String] = [] {
        didSet {
            render()
        }
    }
    
    // MARK: - Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configUI()
    }
    
    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setting
    
    private func render() {
        tagList.forEach { tag in
            let tagLabel = PostTagLabel()
            tagLabel.text = tag
            self.addArrangedSubview(tagLabel)
        }
    }
    
    private func configUI() {
        self.spacing = 8
        self.axis = .horizontal
    }
}
