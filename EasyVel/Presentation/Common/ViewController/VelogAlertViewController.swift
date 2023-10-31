//
//  VelogAlertViewController.swift
//  VelogOnMobile
//
//  Created by 장석우 on 2023/07/05.
//

import UIKit

import SnapKit
import RxSwift
import RxCocoa
import RxGesture

enum AlertType {
    case deleteTag
    case unsubscribe
    case signOut
    case withdrawal
    
    var title: String? {
        switch self {
        case .signOut:
            return "로그아웃"
        case .withdrawal:
            return "회원탈퇴"
        default:
            return nil
        }
    }
    
    var description: String {
        switch self {
        case .deleteTag:
            return "정말 태그를 삭제하시겠습니까?"
        case .unsubscribe:
            return "정말 팔로우를 취소하시겠습니까?"
        case .signOut:
            return "정말 로그아웃 하시겠습니까?"
        case .withdrawal:
            return "정말 탈퇴하시겠습니까?"
        }
    }
    
    var subDescription: String? {
        switch self {
        case .withdrawal:
            return "※ 회원님의 데이터가 사라집니다."
        default:
            return nil
        }
    }
    
    var canel: String {
        switch self {
        case .deleteTag, .unsubscribe, .signOut, .withdrawal:
            return "아니요"
        }
    }
    
    var yes: String {
        switch self {
        case .deleteTag:
            return "삭제"
        default:
            return "네"
        }
    }
    
    var hasAlertImage: Bool {
        switch self {
        case .deleteTag, .unsubscribe:
            return true
        default:
            return false
        }
    }
    
    var height: CGFloat {
        switch self {
        case .withdrawal:
            return 196
        default:
            return 188
        }
    }
    
}

protocol VelogAlertViewControllerDelegate: AnyObject {
    func yesButtonDidTap(_ alertType: AlertType)
}

final class VelogAlertViewController: UIViewController {
    
    //MARK: - Properties
    
    private var alertType: AlertType
    
    private weak var delegate: VelogAlertViewControllerDelegate?
    private let disposeBag = DisposeBag()
    
    //MARK: - UI Components
    
    private let alertView = UIView()
    private let dimmedView = UIView()
    private let alertImageView = UIImageView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let subDescriptionLabel = UILabel()
    private let cancelButton = UIButton()
    private let yesButton = UIButton()
    
    private lazy var descriptionStackView = UIStackView(arrangedSubviews: [descriptionLabel,
                                                                subDescriptionLabel])
    
    //MARK: - Life Cycle
    
    init(alertType: AlertType, delegate: VelogAlertViewControllerDelegate) {
        self.alertType = alertType
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
        
        style()
        hierarchy()
        layout()
        updateUI(alertType)
    }
    
    //MARK: - Custom Method
    
    private func bind() {
        dimmedView.rx.tapGesture()
            .when(.recognized)
            .asDriver(onErrorJustReturn: .init())
            .drive(with: self, onNext: { owner, _ in
                owner.dismiss(animated: false)
            })
            .disposed(by: disposeBag)
        
        yesButton.rx.tap
            .asDriver(onErrorJustReturn: Void())
            .drive(with: self, onNext: { owner, _ in
                owner.dismiss(animated: false)
                owner.delegate?.yesButtonDidTap(owner.alertType)
            })
            .disposed(by: disposeBag)
        
        cancelButton.rx.tap
            .asDriver(onErrorJustReturn: Void())
            .drive(with: self, onNext: { owner, _ in
                owner.dismiss(animated: false)
            })
            .disposed(by: disposeBag)
        
    }
    
    private func style() {
        view.backgroundColor = .clear
        
        alertView.backgroundColor = .white
        alertView.makeRounded(radius: 14)
        alertView.alpha = 1
        
        dimmedView.backgroundColor = .black
        dimmedView.alpha = 0.45
        
        alertImageView.image = ImageLiterals.alertIcon
        alertImageView.contentMode = .scaleAspectFit
        
        titleLabel.font = .subhead
        titleLabel.textColor = .gray700
        
        descriptionLabel.font = .body_2_M
        descriptionLabel.textColor = .gray500
        
        subDescriptionLabel.font = .caption_1_M
        subDescriptionLabel.textColor = .error
        
        cancelButton.backgroundColor = .gray100
        cancelButton.setTitleColor(.gray300, for: .normal)
        cancelButton.titleLabel?.textAlignment = .center
        cancelButton.titleLabel?.font = .body_2_M
        cancelButton.makeRounded(radius: 4)
        
        yesButton.backgroundColor = .brandColor
        yesButton.setTitleColor(.white, for: .normal)
        yesButton.titleLabel?.textAlignment = .center
        yesButton.titleLabel?.font = .body_2_M
        yesButton.makeRounded(radius: 4)
        
        descriptionStackView.axis = .vertical
        descriptionStackView.spacing = 4
        descriptionStackView.alignment = .center
        descriptionStackView.distribution = .fillEqually
    }
    
    private func hierarchy() {
        view.addSubviews(dimmedView,alertView)
        alertView.addSubviews(alertImageView,
                              titleLabel,
                              descriptionStackView,
                              cancelButton,
                              yesButton)
    }
    
    private func layout() {
        alertView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.width.equalTo(300)
            $0.height.equalTo(alertType.height)
        }
        
        dimmedView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        
        alertImageView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(20)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(44)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(26)
            $0.centerX.equalToSuperview()
        }
        
        descriptionStackView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-6)
        }
        
        cancelButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(16)
            $0.leading.equalToSuperview().inset(20)
            $0.width.equalTo(124)
            $0.height.equalTo(40)
        }
        
        yesButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(16)
            $0.trailing.equalToSuperview().inset(20)
            $0.width.equalTo(124)
            $0.height.equalTo(40)
        }
    }
    
    private func updateUI(_ type: AlertType) {
        titleLabel.text = type.title
        descriptionLabel.text = type.description
        subDescriptionLabel.text = type.subDescription
        cancelButton.setTitle(type.canel, for: .normal)
        yesButton.setTitle(type.yes, for: .normal)
        
        alertImageView.isHidden = !type.hasAlertImage
        subDescriptionLabel.isHidden = (type.subDescription == nil)   
    }
}

