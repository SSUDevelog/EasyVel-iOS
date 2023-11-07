//
//  PostWebViewModel.swift
//  EasyVel
//
//  Created by 이성민 on 11/7/23.
//

import Foundation

import RxCocoa
import RxSwift

final class PostWebViewModel: BaseViewModel, ViewModelType {
    
    // MARK: - Properties
    
    private let followService: FollowService
    private let storagePost: StoragePost
    
    private let realm = RealmService()
    private let backgroundQueue = ConcurrentDispatchQueueScheduler(queue: .global())
    
    private var isFollowing: Bool?
    private var isScrapped: Bool?
    
    // MARK: - Input & Output
    
    struct Input {
        let viewWillAppear: Observable<Void>
        let followTrigger: Observable<Void>
        let scrapTrigger: Observable<Void>
        
        init(_ viewWillAppear: Observable<Void>,
             _ followTrigger: Observable<Void>,
             _ scrapTrigger: Observable<Void>) {
            self.viewWillAppear = viewWillAppear
            self.followTrigger = followTrigger
            self.scrapTrigger = scrapTrigger
        }
    }
    
    struct Output {
        let webRequest: Driver<URLRequest?>
        let isFollowing: Driver<Bool>
        let isScrapped: Driver<Bool>
        let followTriggerReceived: Driver<Bool?>
        let scrapTriggerReceived: Driver<Bool?>
        
        init(_ webRequest: Driver<URLRequest?>,
             _ isFollowing: Driver<Bool>,
             _ isScrapped: Driver<Bool>,
             _ followTriggerReceived: Driver<Bool?>,
             _ scrapTriggerReceived: Driver<Bool?>) {
            self.webRequest = webRequest
            self.isFollowing = isFollowing
            self.isScrapped = isScrapped
            self.followTriggerReceived = followTriggerReceived
            self.scrapTriggerReceived = scrapTriggerReceived
        }
    }
    
    // MARK: - Initialize
    
    init(
        _ followService: FollowService,
        _ storagePost: StoragePost
    ) {
        self.followService = followService
        self.storagePost = storagePost
    }
    
    // MARK: - Transform
    
    func transform(input: Input, disposeBag: RxSwift.DisposeBag) -> Output {
        let webRequest = input.viewWillAppear
            .startWith(LoadingView.showLoading())
            .map { [weak self] _ -> URLRequest? in
                guard let self = self else { return nil }
                
                guard let urlString = self.storagePost.url,
                      urlString.isValidURL,
                      let encodedString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                      let url = URL(string: encodedString)
                else { return nil }
                
                return URLRequest(url: url)
            }
            .asDriver(onErrorJustReturn: nil)
        
        let isFollowing = input.viewWillAppear
            .flatMapLatest { [weak self] _ -> Observable<[FollowListResponse]> in
                guard let self = self else { return Observable.empty() }
                return self.getFollowingList()
            }
            .map { [weak self] followingListResponse -> Bool in
                guard let self = self,
                      let name = self.storagePost.name
                else { return false }
                
                let followingList = followingListResponse.map { $0.name }
                self.isFollowing = followingList.contains(name)
                
                guard let isFollowing = self.isFollowing else { return false }
                return isFollowing
            }
            .asDriver(onErrorJustReturn: false)
        
        let isScrapped = input.viewWillAppear
            .map { [weak self] _ -> Bool in
                guard let self = self else { return false }
                
                self.isScrapped = self.realm.containsPost(input: self.storagePost)
                
                guard let isScrapped = self.isScrapped else { return false }
                return isScrapped
            }
            .asDriver(onErrorJustReturn: false)
        
        let followTriggerReceived = input.followTrigger
            .map { [weak self] _ -> Bool? in
                guard let self = self else { return nil }
                
                guard let isFollowing = self.isFollowing,
                      let author = self.storagePost.name
                else { return nil }
                
                if isFollowing {
                    self.unfollow(author: author)
                    return false
                } else {
                    self.follow(author: author)
                    return true
                }
            }
            .asDriver(onErrorJustReturn: nil)
        
        let scrapTriggerReceived = input.scrapTrigger
            .map { [weak self] _ -> Bool? in
                guard let self = self else { return nil }
                
                guard let isScrapped = self.isScrapped,
                      let url = self.storagePost.url
                else { return nil }
                
                if isScrapped {
                    self.realm.deletePost(url: url)
                    return false
                } else {
                    NotificationCenter.default.post(name: Notification.Name("ScrapButtonTappedNotification"), object: nil, userInfo: ["data" : self.storagePost])
                    return true
                }
            }
            .asDriver(onErrorJustReturn: nil)
        
        
        return Output(webRequest, isFollowing, isScrapped, followTriggerReceived, scrapTriggerReceived)
    }
    
    // MARK: - Functions
    
}

extension PostWebViewModel {
    private func scrap(
        post: StoragePost
    ) {
        NotificationCenter.default.post(name: Notification.Name("ScrapButtonTappedNotification"), object: nil, userInfo: ["data" : post])
    }
    
    private func getFollowingList() -> Observable<[FollowListResponse]> {
        Observable<[FollowListResponse]>.create { observer in
            self.followService.getFollowList { [weak self] result in
                switch result {
                case .success(let response):
                    guard let list = response as? [FollowListResponse] else {
                        self?.serverFailOutput.accept(true)
                        observer.onError(NSError(domain: "ParsingError", code: 0, userInfo: nil))
                        return
                    }
                    observer.onNext(list)
                    observer.onCompleted()
                case .requestErr(_):
                    self?.serverFailOutput.accept(true)
                    observer.onError(NSError(domain: "requestErr", code: 0, userInfo: nil))
                default:
                    self?.serverFailOutput.accept(true)
                    observer.onError(NSError(domain: "UnknownError", code: 0, userInfo: nil))
                }
            }
            return Disposables.create()
        }
    }
    
    private func follow(
        author: String
    ) {
        followService.addFollow(
            fcmToken: TextLiterals.noneText,
            name: author
        ) { [weak self] result in
            switch result {
            case .success(_): break
            case .requestErr(_):
                self?.serverFailOutput.accept(true)
            default:
                self?.serverFailOutput.accept(true)
            }
        }
    }
    
    func unfollow(
        author: String
    ) {
        followService.deleteFollow(
            targetName: author
        ) { [weak self] result in
            switch result {
            case .success(_): break
            case .requestErr(_):
                self?.serverFailOutput.accept(true)
            default:
                self?.serverFailOutput.accept(true)
            }
        }
    }
}
