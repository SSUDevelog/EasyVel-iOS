//
//  UITextField+Extension.swift
//  VelogOnMobile
//
//  Created by 홍준혁 on 2023/06/22.
//

import UIKit

extension UITextField {
    func addLeftPadding(
        leftPaddingWidth: Int
    ) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: leftPaddingWidth, height: Int(self.frame.height)))
        self.leftView = paddingView
        self.leftViewMode = ViewMode.always
    }
    
    func addRightButton(
        image: UIImage,
        action: UIAction,
        at mode: UITextField.ViewMode
    ) {
        let rightButton = UIButton()
        rightButton.setImage(image, for: .normal)
        rightButton.frame = .init(x: 0, y: 0, width: 16, height: 16)
        rightButton.addAction(action, for: .touchUpInside)
        self.rightView = rightButton
        self.rightViewMode = mode
    }
}
