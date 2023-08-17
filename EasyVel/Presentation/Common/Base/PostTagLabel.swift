//
//  PostTagUIButton.swift
//  VelogOnMobile
//
//  Created by 홍준혁 on 2023/05/11.
//

import UIKit

import SnapKit

class PostTagLabel: UILabel {
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        setUI()
    }
    
    private func setUI() {
        self.backgroundColor = .brandColor
        self.textColor = .white
        self.font = .body_1_M
        self.textAlignment = .center
        self.makeRounded(ratio: 2)
        
        self.snp.makeConstraints {
            $0.width.equalTo(intrinsicContentSize.width + 24)
            $0.height.equalTo(intrinsicContentSize.height + 4)
        }
    }
    
}
