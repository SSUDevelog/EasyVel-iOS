//
//  HomeView.swift
//  EasyVel
//
//  Created by 장석우 on 2023/10/05.
//

import UIKit

import SnapKit

final class HomeView: UIView {
    
    let navigationView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = TextLiterals.homeViewControllerHeadTitle
        label.font = .display
        return label
    }()
    
    let searchButton: UIButton = {
        let button = UIButton()
        button.setImage(ImageLiterals.searchIcon, for: .normal)
        return button
    }()
    
    let menuBar = HomeMenuBar()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        style()
        hierarchy()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func style() {
        backgroundColor = .gray100
    }
    
    private func hierarchy() {
        addSubviews(navigationView, menuBar)
        
        navigationView.addSubviews(titleLabel, searchButton)
    }
    
    private func layout() {
        // view
        navigationView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(132)
        }
        
        menuBar.snp.makeConstraints {
            $0.top.equalTo(navigationView.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(40)
        }
        
        
        // naviagtionView
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(76)
            $0.leading.equalToSuperview().inset(17)
        }
        
        searchButton.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.trailing.equalToSuperview().inset(22)
            $0.size.equalTo(30)
        }
    }
}
