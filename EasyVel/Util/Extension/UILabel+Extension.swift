//
//  UILabel+Extension.swift
//  EasyVel
//
//  Created by 이성민 on 2023/09/21.
//

import UIKit

extension UILabel {
    func setLineHeight(
        multiple: CGFloat,
        with text: String = " "
    ) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = multiple
        attributedText = NSMutableAttributedString(
            string: text,
            attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle]
        )
    }
}
