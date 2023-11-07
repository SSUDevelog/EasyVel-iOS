//
//  FolderAlertViewController.swift
//  EasyVel
//
//  Created by JEONGEUN KIM on 11/3/23.
//

import UIKit

import SnapKit
import RxSwift
import RxCocoa
import RxGesture


enum FolderType {
    case create
    case change
    
    var title: String {
        switch self {
        case .create:
            return "폴더 추가"
        case .change:
            return "폴더 이름 변경"
        }
    }
}

protocol FolderViewControllerDelegate: AnyObject {
    
    func folderVCDismiss(newFolderName: String)
}

final class FolderAlertViewController: UIViewController {
    
    // MARK: - Properties
    
    private var type: FolderType?
    var delegate: FolderViewControllerDelegate?
    
    private var viewmodel: FolderAlertViewModel?
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Components
    
    private let alertView = UIView()
    private let titleLabel = UILabel()
    private let folderTextFiled = FolderTextField()
    private let errorLabel = UILabel()
    private var yesButton = UIButton()
    private let noButton = UIButton()
    private let buttonStackView = UIStackView()
    
    // MARK: - Life Cycle
    
    init(type: FolderType, folderName: String = "") {
        super.init(nibName: nil, bundle:  nil)
        self.type = type
        self.viewmodel = FolderAlertViewModel(viewType: type, folderName: folderName)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
        hierarchy()
        layout()
        style()
    }
    
    private func bind() {

        let input = FolderAlertViewModel.Input(addFolderInput: folderTextFiled.rx.text.orEmpty.asObservable(),
                                               yesDidTap: yesButton.rx.tap)
        guard let viewmodel = self.viewmodel else { return }
        let output = viewmodel.transform(input: input)

        output.errorMessage
            .map { $0.isEnabled }
            .drive(yesButton.rx.isEnabled)
            .disposed(by: disposeBag)

        output.errorMessage
            .map { $0.rawValue }
            .drive(errorLabel.rx.text)
            .disposed(by: disposeBag)
   
        output.folderName
            .asDriver(onErrorJustReturn: "")
            .drive(with: self, onNext: { owner, newfolder in
                owner.errorLabel.isHidden = true
                owner.dismiss(animated: true)
                owner.delegate?.folderVCDismiss(newFolderName: newfolder)
            })
            .disposed(by: disposeBag)
        
        folderTextFiled.clearButton.rx.tap
            .withLatestFrom(Observable.just(""))
            .do(onNext: { self.errorLabel.text = $0 })
            .bind(to: folderTextFiled.rx.text)
            .disposed(by: disposeBag)
        
        noButton.rx.tap
            .asDriver(onErrorJustReturn: Void())
            .drive(with: self, onNext: { owner, _ in
                owner.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        
    }
    
    private func hierarchy() {
        view.addSubview(alertView)
        alertView.addSubviews(titleLabel,
                              folderTextFiled,
                              errorLabel,
                              buttonStackView)
        buttonStackView.addArrangedSubviews(noButton, yesButton)
        
    }
    
    private func layout() {
        alertView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.height.equalTo(208)
            $0.width.equalTo(299)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.centerX.equalToSuperview()
        }
        
        folderTextFiled.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(36)
        }

        errorLabel.snp.makeConstraints {
            $0.top.equalTo(folderTextFiled.snp.bottom).offset(8)
            $0.centerX.equalToSuperview()
        }
        
        buttonStackView.snp.makeConstraints {
            $0.top.equalTo(folderTextFiled.snp.bottom).offset(48)
            $0.bottom.equalToSuperview().inset(16)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
        
        noButton.snp.makeConstraints {
            $0.width.equalTo(buttonStackView.snp.width).dividedBy(2).inset(3)
        }
    }
    
    private func style() {
        view.backgroundColor = .black.withAlphaComponent(0.45)
        
        alertView.backgroundColor = .white
        alertView.makeRounded(radius: 8)
        
        titleLabel.font = .subhead
        titleLabel.textColor = .gray700
        titleLabel.text = type?.title
     
        errorLabel.font = .caption_1_M
        errorLabel.textColor = .error
        
        folderButtonStyle(type: noButton,
                          title: TextLiterals.addFolderAlertCancelActionTitle,
                          backgroundColor: .gray100,
                          titleColor: .gray300)
        
        folderButtonStyle(type: yesButton,
                          title: TextLiterals.addFolderAlertOkActionTitle,
                          backgroundColor: .brandColor,
                          titleColor: .white)
        
        buttonStackView.spacing = 12
        buttonStackView.axis = .horizontal
        
    }

    
    private func folderButtonStyle(type: UIButton,
                                   title: String,
                                   backgroundColor: UIColor,
                                   titleColor: UIColor){
        
        let button = type
        button.backgroundColor = backgroundColor
        button.setTitle(title, for: .normal)
        button.setTitleColor(titleColor, for: .normal)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = .body_2_M
        button.makeRounded(radius: 4)
    }
}


