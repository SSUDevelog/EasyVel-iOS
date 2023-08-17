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
        
        configUI()
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + 24, height: 28)
    }
    
    private func configUI() {
        self.backgroundColor = .brandColor
        self.textColor = .white
        self.font = .body_1_M
        self.textAlignment = .center
        self.makeRounded(ratio: 2)
    }
    
}
