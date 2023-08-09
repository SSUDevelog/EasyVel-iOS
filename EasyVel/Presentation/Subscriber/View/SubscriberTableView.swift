//
//  ListTableView.swift
//  VelogOnMobile
//
//  Created by 홍준혁 on 2023/04/30.
//

import UIKit

import SnapKit

final class SubscriberTableView: UITableView {
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        setupTableView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func setupTableView() {
        register(cell: SubscriberTableViewCell.self)
        separatorStyle = .none
        showsVerticalScrollIndicator = true
        isHidden = true
        rowHeight = 62
        backgroundColor = .gray100
        contentInset.top = 20
    }
}
