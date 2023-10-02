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
    
    var tagList: [String] = []
    
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
    
//    private func render() {
//        self.tagList.forEach { tag in
//            let tagLabel = PostTagLabel()
//            tagLabel.text = tag
//            self.addArrangedSubview(tagLabel)
//        }
//    }
    
    private func configUI() {
        self.spacing = 8
        self.axis = .horizontal
    }
}

extension PostTagStackView {
    func configureTags(_ tags: [String]) {
        var currentTags = [String]()
        self.arrangedSubviews.forEach { label in
            guard let label = label as? UILabel,
                  let text = label.text
            else { return }
            currentTags.append(text)
        }
        
        let newTags = tags.filter { !currentTags.contains($0) }
        newTags.forEach { tag in
            let tagLabel = PostTagLabel()
            tagLabel.text = tag
            self.addArrangedSubview(tagLabel)
        }
    }
}
