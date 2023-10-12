//
//  BaseViewController.swift
//  VelogOnMobile
//
//  Created by 홍준혁 on 2023/04/29.
//

import UIKit

class BaseViewController: UIViewController {
    
    private lazy var backButton = UIBarButtonItem(
        image: ImageLiterals.viewPopButtonIcon,
        style: .plain,
        target: self,
        action: #selector(backButtonTapped)
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        render()
        configUI()
        setupNavigationBar()
        setupNavigationPopGesture()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        navigationController?.navigationBar.isHidden = true
    }
    
    func render() {}
    
    func configUI() {
        view.backgroundColor = .white
    }
    
    func setupNavigationBar() {
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.tintColor = .black
        navigationController?.navigationBar.topItem?.title = TextLiterals.noneText
        navigationItem.leftBarButtonItem = backButton
    }
    
    func setupNavigationPopGesture() {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }
    
    @objc
    func backButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
}
