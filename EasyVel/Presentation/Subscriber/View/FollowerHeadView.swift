//
//  ListHeadView.swift
//  VelogOnMobile
//
//  Created by 홍준혁 on 2023/04/30.
//

import UIKit

import SnapKit

final class FollowerHeadView: BaseUIView {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = TextLiterals.listTitleLabelText
        label.font = .display
        label.textColor = .gray500
        return label
    }()
    
    lazy var searchButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = TextLiterals.followSearchPlaceholderText
        config.image = ImageLiterals.searchGray
        
        config.baseBackgroundColor = .gray100
        config.baseForegroundColor = .gray300
        config.buttonSize = .large
        config.imagePlacement = .all
        config.imagePadding = 8
        let button = UIButton(configuration: config)
        button.makeRounded(radius: 4)
        button.contentHorizontalAlignment = .left
        return button
    }()
    
    private let lineView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray200
        return view
    }()
    
    override func render() {
        self.addSubviews(titleLabel,
                         searchButton,
                         lineView)
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(76)
            $0.centerX.equalToSuperview()
        }
        
        searchButton.snp.makeConstraints {
            $0.bottom.equalTo(lineView.snp.top).offset(-14)
            $0.horizontalEdges.equalToSuperview().inset(30)
            $0.height.equalTo(44)
        }
        
        lineView.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
    
    override func configUI() {
        self.backgroundColor = .white
    }
}

extension FollowerHeadView: UISearchBarDelegate {
    
}
