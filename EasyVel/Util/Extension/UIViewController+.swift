//
//  UIViewController+.swift
//  EasyVel
//
//  Created by 장석우 on 2023/08/29.
//

import UIKit

extension UIViewController {
    func dismissKeyboardWhenTappedAround() {
        print(#function)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                 action: #selector(self.dismissKeyboard))
        tap.cancelsTouchesInView = true
        self.view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
          dismissKeyboard()
    }
    
    func setNotificationCenter(show: Selector, hide: Selector) {
        
        NotificationCenter.default.addObserver(self,
                                               selector: show,
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: hide,
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        
    }
}
