//
//  FolderTextField.swift
//  EasyVel
//
//  Created by JEONGEUN KIM on 11/7/23.
//

import UIKit

final class FolderTextField: UITextField {

    // MARK: - UIComponents
    
    let clearButton = UIButton()
    
    // MARK: - Initialize
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        style()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func style() {
        self.layer.borderColor = UIColor.gray200.cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 4
        self.attributedPlaceholder = NSAttributedString(string: TextLiterals.folderTextFieldPlaceHolder,
                                                                   attributes: [.foregroundColor : UIColor.gray200,
                                                                                .font: UIFont.caption_1_M
                                                                   ])
        self.addLeftPadding(leftPaddingWidth: 12)
        self.rightView = clearButton
        self.rightViewMode = .always
        
        clearButton.setImage(.cancel, for: .normal)

    }
    
    private func layout() {
        clearButton.snp.makeConstraints {
            $0.size.equalTo(16)
        }
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        
        let rect = super.textRect(forBounds: bounds)
        return rect.inset(by: UIEdgeInsets(top: 0,
                                           left: 0,
                                           bottom: 0,
                                           right: 24))
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        
        let rect = super.editingRect(forBounds: bounds)
        return rect.inset(by: UIEdgeInsets(top: 0,
                                           left: 0,
                                           bottom: 0,
                                           right: 24))
    }

    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        
        let rect = super.rightViewRect(forBounds: bounds)
        return rect.inset(by: UIEdgeInsets(top: 0,
                                           left: -12,
                                           bottom: 0,
                                           right: 12))
    }
}


