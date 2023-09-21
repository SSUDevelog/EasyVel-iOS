//
//  NewPostsViewModel.swift
//  EasyVel
//
//  Created by 이성민 on 2023/08/26.
//

import Foundation

import RxSwift
import RxCocoa
import RxRelay

final class NewPostsViewModel: BaseViewModel {
    
    // MARK: - Properties
    
    let realm = RealmService()
    let service = DefaultPostService.shared
    
    private var viewType: ViewType
    private var tag: String
    
    // MARK: - Input
    
    struct Input {
        let postTrigger: Observable<Void>
        
        init(
            _ postTrigger: Observable<Void>
        ) {
            self.postTrigger = postTrigger
        }
    }
    
    struct Output {
        let postList: Driver<[PostDTO]>
        let isPostListEmpty: Driver<Bool>
        
        init(
            _ postList: Driver<[PostDTO]>,
            _ isPostListEmpty: Driver<Bool>
        ) {
            self.postList = postList
            self.isPostListEmpty = isPostListEmpty
        }
    }
    
    // MARK: - Initialize
    
    init(
        viewType: ViewType,
        tag: String = ""
    ) {
        self.viewType = viewType
        self.tag = tag
        
        super.init()
    }
    
    // MARK: - Custom Functions
    
    func transform(input: Input) -> Output {
        let postList = input.postTrigger
            .startWith(LoadingView.showLoading())
            .flatMapLatest { _ -> Observable<[PostDTO]?> in
                self.getPosts()
            }
            .map { dto -> [PostDTO] in
                guard let postList = dto else {
                    return [PostDTO]()
                }
                return postList
            }
            .asDriver(onErrorJustReturn: [])
        
        let isPostListEmpty = postList
            .map { $0.isEmpty }
            .asDriver(onErrorJustReturn: true)
        
        return Output(postList, isPostListEmpty)
    }
    
}

// MARK: - func

extension NewPostsViewModel {
    
    private func convertPostDtoToStoragePost(
        input: PostDTO
    ) -> StoragePost {
        return StoragePost(
            img: input.img ?? "",
            name: input.name ?? "",
            summary: input.summary ?? "",
            title: input.title ?? "",
            url: input.url ?? ""
        )
    }
    
    private func checkIsUniquePost(
        post: StoragePost
    ) -> Bool {
        return realm.checkUniquePost(input: post)
    }
    
    private func getPosts() -> Observable<[PostDTO]?> {
        switch viewType {
        case .trend:
            return self.getTrendPosts()
        case .follow:
            return self.getSubscriberPosts()
        case .keyword:
            return self.getOneTagPosts(tag: self.tag)
        }
    }
    
}

// MARK: - api

extension NewPostsViewModel {
    
    func getOneTagPosts(tag: String) -> Observable<[PostDTO]?> {
        return Observable.create { observer in
            self.service.getOneTagPosts(tag: tag) { [weak self] result in
                switch result {
                case .success(let response):
                    guard let posts = response as? [PostDTO] else {
                        self?.serverFailOutput.accept(true)
                        observer.onError(NSError(domain: "ParsingError", code: 0, userInfo: nil))
                        return
                    }
                    observer.onNext(posts)
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
    
    func getTrendPosts() -> Observable<[PostDTO]?> {
        return Observable.create { observer in
            self.service.getTrendPosts() { [weak self] result in
                switch result {
                case .success(let response):
                    guard let posts = response as? TrendPostResponse else {
                        self?.serverFailOutput.accept(true)
                        observer.onError(NSError(domain: "ParsingError", code: 0, userInfo: nil))
                        return
                    }
                    observer.onNext(posts.trendPostDtos)
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
    
    func getSubscriberPosts() -> Observable<[PostDTO]?> {
        return Observable.create { observer in
            self.service.getSubscriberPosts() { [weak self] result in
                switch result {
                case .success(let response):
                    guard let posts = response as? GetSubscriberPostResponse else {
                        self?.serverFailOutput.accept(true)
                        observer.onError(NSError(domain: "ParsingError", code: 0, userInfo: nil))
                        return
                    }
                    observer.onNext(posts.subscribePostDtoList)
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
    
}
