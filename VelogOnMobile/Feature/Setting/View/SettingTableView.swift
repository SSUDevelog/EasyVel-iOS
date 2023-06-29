//
//  SettingTableView.swift
//  VelogOnMobile
//
//  Created by 홍준혁 on 2023/05/01.
//

import UIKit

final class SettingTableView: UITableView {
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        setupTableView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func setupTableView() {
        register(SettingTableViewCell.self, forCellReuseIdentifier: SettingTableViewCell.cellId)
        dataSource = self
        separatorStyle = .singleLine
        showsVerticalScrollIndicator = false
        backgroundColor = .white
        isScrollEnabled = false
    }
}

extension SettingTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.dequeueReusableCell(withIdentifier: SettingTableViewCell.cellId, for: indexPath) as? SettingTableViewCell else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        let row = indexPath.row
        switch row {
        case 0: cell.buttonLabel.text = TextLiterals.settingSignOutText
        case 1: cell.buttonLabel.text = TextLiterals.settingWithdrawalText
        default: return cell
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
}
