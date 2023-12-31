//
//  TabBarController.swift
//  VelogOnMobile
//
//  Created by 홍준혁 on 2023/04/29.
//

import UIKit

import SnapKit
import RxSwift
import RxRelay

import RealmSwift
import Realm

final class TabBarController: UITabBarController {
    
    private var userLocalVersion: String? {
        guard let dictionary = Bundle.main.infoDictionary,
            let version = dictionary["CFBundleShortVersionString"] as? String else {return nil}
        let versionAndBuild: String = version
        return versionAndBuild
    }
    private var appLatestVersion: String? {
        didSet {
            if let userLocalVersion = userLocalVersion,
               let appLatestVersion = appLatestVersion {
                if checkUpdateAvailable(userLocalVersion: userLocalVersion, appLatestVersion: appLatestVersion) {
                    presentUpdateAlertVC()
                }
            }
        }
    }

    // MARK: - viewModel properties
    
    let listViewModel = FollowViewModel(service: DefaultFollowService.shared)
    let scrapStorageViewModel = ScrapStorageViewModel()
    
    // MARK: - viewController properties
    
    let homeVC = HomeViewController(viewModel: HomeViewModel(service: DefaultTagService.shared))
    lazy var listVC = FollowViewController(viewModel: listViewModel)
    lazy var storageVC = ScrapStorageViewController(viewModel: scrapStorageViewModel)
    let settingViewModel = SettingViewModel(service: DefaultAuthService.shared)
    lazy var settingVC = SettingViewController(viewModel: settingViewModel)
    
    
    // MARK: - view properties
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getLatestVersion()
        setUpTabBar()
        setDelegate()
        setNotificationCenter()
//        self.resetDB()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        tabBar.frame.size.height = 96
        tabBar.frame.origin.y = view.frame.height - 96

    }
    
    private func setLayout(scrapPopUpView: UIView) {
        
        UIApplication.shared.firstWindow?.addSubview(scrapPopUpView)
        
        scrapPopUpView.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(108)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(108)
        }
    }
    
    private func setNotificationCenter() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleNotification(_:)),
            name: Notification.Name("ScrapButtonTappedNotification"),
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(goToScrapButtonDidTap),
            name: Notification.Name("MoveToScrapStorage"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateHomeVC),
            name: Notification.Name("updateHomeVC"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateFollowVC),
            name: Notification.Name("updateFollowVC"),
            object: nil
        )
        
        
    }
    
    @objc
    private func handleNotification(_ notification: Notification) {
        
        guard let data = notification.userInfo?["data"] as? StoragePost else {
            return
        }
        
        let scrapPopUpView = ScrapPopUpView(storagePost: data)
        scrapPopUpView.delegate = self
        setLayout(scrapPopUpView: scrapPopUpView)
        
        UIApplication.shared.firstWindow?.layoutIfNeeded()
        
        scrapPopUpView.snp.updateConstraints {
            $0.bottom.equalToSuperview()
        }
        
        UIView.animate(withDuration: 0.5) {
            UIApplication.shared.firstWindow?.layoutIfNeeded()
        } completion: { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                scrapPopUpView.snp.updateConstraints {
                    $0.bottom.equalToSuperview().offset(108)
                }
                UIView.animate(withDuration: 0.5) {
                    UIApplication.shared.firstWindow?.layoutIfNeeded()
                }
            })
        }
    }
    
    @objc
    private func updateHomeVC() {
        self.homeVC.updateHomeEvent.accept(Void())
    }
    
    @objc
    private func updateFollowVC() {
        self.listViewModel.refreshFollowList.accept(true)
    }
    
    private func setUpTabBar(){
        self.tabBar.tintColor = .brandColor
        self.tabBar.unselectedItemTintColor = .gray300
        self.tabBar.isTranslucent = false
        self.tabBar.backgroundColor = .white
        self.tabBar.itemSpacing = 100
        
        let line = UIView()
        line.backgroundColor = .gray200
        
        
        tabBar.addSubviews(line)
        line.snp.makeConstraints {
            $0.top.equalTo(tabBar)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        

        homeVC.title = TextLiterals.homeViewControllerTitle
        listVC.title = TextLiterals.listViewControllerTitle
        storageVC.title = TextLiterals.storageViewControllerTitle
        settingVC.title = TextLiterals.settingViewControllerTitle

        let ViewControllers:[UIViewController] = [homeVC,listVC,storageVC,settingVC]
        self.setViewControllers(ViewControllers, animated: true)

        
        homeVC.tabBarItem = UITabBarItem(title: "홈",
                                               image: ImageLiterals.home,
                                               selectedImage: ImageLiterals.homeFill)
        listVC.tabBarItem = UITabBarItem(title: "팔로워",
                                               image: ImageLiterals.list,
                                               selectedImage: ImageLiterals.listFill)
        storageVC.tabBarItem = UITabBarItem(title: "스크랩",
                                                  image: ImageLiterals.bookMark,
                                                  selectedImage: ImageLiterals.bookMarkFill)
        settingVC.tabBarItem = UITabBarItem(title: "설정",
                                                  image: ImageLiterals.my,
                                                  selectedImage: ImageLiterals.myFill)
        
        self.hidesBottomBarWhenPushed = false
        viewWillLayoutSubviews()
    }

    private func setDelegate() {
        delegate = self
    }
}

extension TabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        NotificationCenter.default.post(
            name: Notification.Name("scrollToTop"),
            object: nil
        )
        let impactService = Haptic.impact(.light)
        impactService.run()
    }
}

extension TabBarController: ScrapPopUpDelegate {
    @objc
    func goToScrapButtonDidTap() {
        selectedIndex = 2
    }
    
    func putInFolderButtonDidTap(scrapPost: StoragePost) {
        let viewModel = ScrapFolderBottomSheetViewModel()
        viewModel.selectedScrapPostAddInFolder.accept(scrapPost)
        let folderViewController = ScrapFolderBottomSheetViewController(viewModel: viewModel)
        folderViewController.modalPresentationStyle = .pageSheet
        self.present(folderViewController, animated: true)
    }
}

extension TabBarController {
    private func checkUpdateAvailable(
        userLocalVersion: String,
        appLatestVersion: String
    ) -> Bool {
        let userLocalVersionArray: [Int] = userLocalVersion.split(separator: ".").map { Int($0) ?? 0 }
        let appLatestVersionArray: [Int] = appLatestVersion.split(separator: ".").map { Int($0) ?? 0 }
        
        if userLocalVersionArray[0] < appLatestVersionArray[0] {
            return true
        } else {
            return userLocalVersionArray[1] < appLatestVersionArray[1] ? true : false
        }
    }
    
    private func presentUpdateAlertVC() {
        let alertVC = UIAlertController(title: "업데이트", message: "업데이트가 필요합니다.", preferredStyle: .alert)
        let alertAtion = UIAlertAction(title: "업데이트", style: .default) { _ in
            let appleID = "6448953485"
            guard let url = URL(string: "itms-apps://itunes.apple.com/app/\(appleID)") else { return }
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
        alertVC.addAction(alertAtion)

        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alertVC.addAction(cancelAction)

        present(alertVC, animated: true)
    }
    
    func getLatestVersion() {
        DefaultVersionService.shared.getVersion {
            result in
            switch result {
            case .success(let response):
                guard let response = response as? VersionCheckDTO else { return }
                self.appLatestVersion = response.version
            default :
                return
            }
        }
    }
}

extension TabBarController {
    // 스키마 수정시 한번 돌려야 한다.
    func resetDB(){
        let realmURL = Realm.Configuration.defaultConfiguration.fileURL!
        let realmURLs = [
          realmURL,
          realmURL.appendingPathExtension("lock"),
          realmURL.appendingPathExtension("note"),
          realmURL.appendingPathExtension("management")
        ]

        for URL in realmURLs {
          do {
            try FileManager.default.removeItem(at: URL)
          } catch {
            // handle error
          }
        }
    }
}
