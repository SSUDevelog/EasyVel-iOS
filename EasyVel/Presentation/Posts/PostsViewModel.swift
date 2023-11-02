//
//  PostsViewModel.swift
//  EasyVel
//
//  Created by 이성민 on 2023/08/26.
//

import Foundation

import RxSwift
import RxCocoa
import RxRelay

final class PostsViewModel: BaseViewModel {
    
    // MARK: - Properties
    
    let realm = RealmService()
    let service = DefaultPostService.shared
    
    private var viewType: ViewType
    private var tag: String
    
    // MARK: - Input
    
    struct Input {
        let viewDidLoadEvent: Observable<Void>
        let refreshEvent: Observable<Void>
        let scrapButtonDidTap: Observable<PostModel>
    }
    
    struct Output {
        let postList: Driver<[PostModel]>
        let isPostListEmpty: Driver<Bool>
        let suceessScrap: Driver<Void>
        
        init(_ postList: Driver<[PostModel]>,
             _ isPostListEmpty: Driver<Bool>) {
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
        let postList = Observable<Void>.merge(input.viewDidLoadEvent,
                                              input.refreshEvent)
            .startWith(LoadingView.showLoading())
            .flatMapLatest { _ -> Observable<[PostDTO]?> in
                self.getPosts()
            }
            .map { postDTOs -> [PostDTO] in
                return postDTOs ?? []
            }
            .map { posts -> [PostModel] in
                return posts.map { $0.toPostModel(isScrapped: <#T##Bool#>) }
            }
            .asDriver(onErrorJustReturn: [])
        
        let isPostListEmpty = postList
            .map { $0.isEmpty }
            .asDriver(onErrorJustReturn: true)
        
        let successScrap = input.scrapButtonDidTap
            .flatMapLatest { post -> Observable<Void> in
                self.scrapPost(post)
            }
        
        return Output(postList, isPostListEmpty, successScrap)
    }
    
}

// MARK: - func

extension PostsViewModel {

    
    private func scrapPost(
        _ model: PostModel
    ) {
        let storagePost = model.post.toStoragePost()
        if isPostScrapped(post: storagePost) {
            guard let url = storagePost.url else { return }
            self.realm.deletePost(url: url)
        } else {
            self.realm.addPost(item: storagePost, folderName: TextLiterals.allPostsScrapFolderText)
        }
    }
    
    private func isPostScrapped(
        post: StoragePost
    ) -> Bool {
        return realm.containsPost(input: post)
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

extension PostsViewModel {
    
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
